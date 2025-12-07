import sys
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.box import ROUNDED
from rich.columns import Columns
from rich.text import Text
from rich.tree import Tree
from rich.json import JSON
from rich.markdown import Markdown

from config import BASE_DEFAULT_CONFIG, CATEGORIES

class Display:
    """Base class for all display themes."""

    def __init__(self, console, config, data, fields_to_show):
        """
        Initializes the Display class.

        Args:
            console (Console): The rich console object.
            config (dict): The configuration dictionary.
            data (dict): The IP information dictionary.
            fields_to_show (list): A list of fields to show in the output.
        """
        self.console = console
        self.config = config
        self.data = data
        self.fields_to_show = fields_to_show
        self.style = self.config.get("style", BASE_DEFAULT_CONFIG["style"])
        self.current_fields = self._get_current_fields()

    def _get_current_fields(self):
        """
        Returns the list of fields to display.

        Returns:
            list: A list of fields to display.
        """
        if not self.fields_to_show:
            return self.config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
        if 'all' in self.fields_to_show:
            return [key for key in self.data if key != "status"]
        return self.fields_to_show

    def display(self):
        """Displays the IP information."""
        raise NotImplementedError

    def _make_info_table(self, fields):
        """
        Creates a rich Table with the IP information.

        Args:
            fields (list): A list of fields to include in the table.

        Returns:
            Table: A rich Table object.
        """
        table = Table(box=None, show_header=False, padding=(0, 1))
        table.add_column(style=self.style.get("field_name", "cyan"))
        table.add_column(style=self.style.get("field_value", "white"))
        for field in fields:
            if field in self.data:
                table.add_row(f"{field.capitalize()}:", str(self.data[field]))
        return table


class SleekDisplay(Display):
    """Displays the IP information in a sleek table."""

    def display(self):
        table = Table(box=ROUNDED, show_header=True, header_style=self.style.get("header", "bold white on blue"))
        table.add_column("Field", style=self.style.get("field_name", "cyan"), no_wrap=True)
        table.add_column("Value", style=self.style.get("field_value", "white"))

        for field in self.current_fields:
            if field in self.data:
                table.add_row(field.capitalize(), str(self.data[field]))
        
        panel_title = f"Information for [bold]{self.data.get('display_ip', 'N/A')}[/bold]"
        self.console.print(
            Panel(
                table,
                title=panel_title,
                border_style=self.style.get("panel_border", "blue"),
                expand=False
            )
        )

class DashboardDisplay(Display):
    """Displays the IP information in a dashboard."""

    def display(self):
        self.console.print(Panel(f"[bold]Information for {self.data.get('display_ip', 'N/A')}[/bold]", expand=False, border_style=self.style.get("panel_border", "blue")))

        panels = []
        
        processed_fields = set()
        for cat_name, cat_fields in CATEGORIES.items():
            fields_in_cat = [f for f in cat_fields if f in self.current_fields]
            table = self._make_info_table(fields_in_cat)
            if table.row_count > 0:
                panels.append(Panel(table, title=f"[bold]{cat_name}[/bold]", border_style=self.style.get("panel_border", "blue"), expand=True))
                processed_fields.update(fields_in_cat)

        other_fields = [f for f in self.current_fields if f not in processed_fields and f not in ['query', 'status']]
        if other_fields:
            other_table = self._make_info_table(other_fields)
            if other_table.row_count > 0:
                panels.append(Panel(other_table, title="[bold]Other[/bold]", border_style=self.style.get("panel_border", "blue"), expand=True))
        
        if panels:
            self.console.print(Columns(panels, expand=True))
    

class JsonDisplay(Display):
    """Displays the IP information in JSON format."""

    def display(self):
        output_data = {field: self.data[field] for field in self.current_fields if field in self.data}
        self.console.print(JSON.from_data(output_data))

class CompactDisplay(Display):
    """Displays the IP information in a compact format."""

    def display(self):
        text = Text()
        query = self.data.get('display_ip', 'N/A')
        text.append(f"IP: {query}", style="bold")

        for field in self.current_fields:
            if field in self.data and field != 'query':
                text.append(" | ", style="dim")
                text.append(f"{field.capitalize()}: ", style=self.style.get('field_name', 'cyan'))
                text.append(str(self.data[field]), style=self.style.get('field_value', 'white'))
                
        self.console.print(text)

class GridDisplay(Display):
    """Displays the IP information in a grid."""

    def display(self):
        table = Table(box=ROUNDED, show_header=True, header_style=self.style.get("header", "bold white on blue"), title=f"Information for [bold]{self.data.get('display_ip', 'N/A')}[/bold]")
        table.add_column("Category", style="bold", no_wrap=True)
        table.add_column("Field", style=self.style.get("field_name", "cyan"))
        table.add_column("Value", style=self.style.get("field_value", "white"))
        
        processed_fields = set()
        
        for cat_name, cat_fields in CATEGORIES.items():
            fields_to_show_in_cat = [f for f in cat_fields if f in self.current_fields and f in self.data]
            if not fields_to_show_in_cat:
                continue
            
            first_in_cat = True
            for field in fields_to_show_in_cat:
                category_cell = f"[{self.style.get('panel_border', 'blue')}]{cat_name}[/]" if first_in_cat else ""
                table.add_row(category_cell, field.capitalize(), str(self.data[field]))
                first_in_cat = False
                processed_fields.add(field)

        other_fields = [f for f in self.current_fields if f not in processed_fields and f not in ['query', 'status'] and f in self.data]
        if other_fields:
            first_in_cat = True
            for field in other_fields:
                category_cell = f"[{self.style.get('panel_border', 'blue')}]Other[/]" if first_in_cat else ""
                table.add_row(category_cell, field.capitalize(), str(self.data[field]))
                first_in_cat = False
                
        self.console.print(table)

class MarkdownDisplay(Display):
    """Displays the IP information in Markdown format."""

    def display(self):
        markdown_string = self.generate_markdown_string()
        self.console.print(Markdown(markdown_string))

    def generate_markdown_string(self):
        markdown_string = f"# IP Information for {self.data.get('display_ip', 'N/A')}\n\n"
        processed_fields = set()

        for cat_name, cat_fields in CATEGORIES.items():
            fields_in_cat = [f for f in cat_fields if f in self.current_fields and f in self.data]
            if fields_in_cat:
                markdown_string += f"## {cat_name}\n"
                for field in fields_in_cat:
                    markdown_string += f"- **{field.capitalize()}**: {self.data[field]}\n"
                markdown_string += "\n"
                processed_fields.update(fields_in_cat)

        other_fields = [f for f in self.current_fields if f not in processed_fields and f not in ['query', 'status'] and f in self.data]
        if other_fields:
            markdown_string += "## Other\n"
            for field in other_fields:
                markdown_string += f"- **{field.capitalize()}**: {self.data[field]}\n"
            markdown_string += "\n"
        
        return markdown_string

class MinimalDisplay(Display):
    """Displays the IP information in a minimal format."""

    def display(self):
        self.console.print(f"--- IP Information for [bold]{self.data.get('display_ip', 'N/A')}[/bold] ---")

        for field in self.current_fields:
            if field in self.data:
                self.console.print(f"[{self.style.get('field_name', 'cyan')}]{field.capitalize()}:[/] [{self.style.get('field_value', 'white')}]{self.data[field]}[/]")

class TreeDisplay(Display):
    """Displays the IP information in a tree."""

    def display(self):
        tree = Tree(
            f"IP Information for [bold]{self.data.get('display_ip', 'N/A')}[/bold]",
            guide_style=self.style.get("panel_border", "blue")
        )

        field_to_category = {field: cat for cat, fields in CATEGORIES.items() for field in fields}

        grouped_fields = {}
        other_fields = []
        
        for field in self.current_fields:
            if field not in self.data:
                continue
            
            category = field_to_category.get(field)
            if category:
                if category not in grouped_fields:
                    grouped_fields[category] = []
                grouped_fields[category].append(field)
            elif field not in ['query', 'status']:
                 other_fields.append(field)
        
        for cat_name in ["Location", "Network", "Details"]:
            if cat_name in grouped_fields:
                branch = tree.add(f"[bold]{cat_name}[/bold]")
                for field in grouped_fields[cat_name]:
                    branch.add(f"[{self.style.get('field_name', 'cyan')}]{field.capitalize()}:[/] [{self.style.get('field_value', 'white')}]{self.data[field]}[/]")

        if other_fields:
            branch = tree.add("[bold]Other[/bold]")
            for field in other_fields:
                branch.add(f"[{self.style.get('field_name', 'cyan')}]{field.capitalize()}:[/] [{self.style.get('field_value', 'white')}]{self.data[field]}[/]")

        self.console.print(tree)


class DisplayManager:
    """Manages the display of IP information."""

    def __init__(self, console):
        """
        Initializes the DisplayManager class.

        Args:
            console (Console): The rich console object.
        """
        self.console = console
        self._displays = {
            "sleek": SleekDisplay,
            "dashboard": DashboardDisplay,
            "tree": TreeDisplay,
            "minimal": MinimalDisplay,
            "json": JsonDisplay,
            "grid": GridDisplay,
            "markdown": MarkdownDisplay,
            "compact": CompactDisplay
        }

    def get_display(self, theme_name, config, data, fields_to_show):
        """
        Returns a display object for the given theme name.

        Args:
            theme_name (str): The name of the theme to use.
            config (dict): The configuration dictionary.
            data (dict): The IP information dictionary.
            fields_to_show (list): A list of fields to show in the output.

        Returns:
            Display: A display object.
        """
        display_class = self._displays.get(theme_name, SleekDisplay)
        return display_class(self.console, config, data, fields_to_show)

    def display(self, data, config, fields_to_show):
        """
        Displays the IP information.

        Args:
            data (dict): The IP information dictionary.
            config (dict): The configuration dictionary.
            fields_to_show (list): A list of fields to show in the output.
        """
        if data.get("status") == "fail":
            style = config.get("style", BASE_DEFAULT_CONFIG["style"])
            error_message = data.get("message", "Unknown error")
            self.console.print(Panel(f"Error: {error_message}", title="[bold red]Request Failed[/bold red]", border_style=style.get("error", "red")))
            return

        theme = config.get("theme", BASE_DEFAULT_CONFIG["theme"])
        display = self.get_display(theme, config, data, fields_to_show)
        display.display()
