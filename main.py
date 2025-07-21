import argparse
import json
import os
import sys
import requests
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.box import ROUNDED
from rich.columns import Columns
from rich.text import Text
from rich.tree import Tree
from rich.json import JSON
from rich.markdown import Markdown

# VERY IMPORTANT: THIS IN NOT THE DEFAULT CONFIG, IT IS JUST A BASE CONFIG FOR THE DEFAULT CONFIG, DON'T CHANGE IT!
# THE DEFAULT CONFIG IS LOADED FROM THE CONFIG.JSON FILE!!!

BASE_DEFAULT_CONFIG = {
    "_comment_theme": "Set the display theme. Options: 'sleek', 'dashboard', 'tree', 'minimal', 'json', 'grid', 'markdown', 'compact'.",
    "theme": "sleek",
    "style": {
        "header": "bold white on blue",
        "field_name": "cyan",
        "field_value": "white",
        "error": "bold red",
        "panel_border": "blue"
    },
    "_comment_fields": "Default fields to display. Add or remove fields from the list below. Use 'all' to see everything.",
    "_all_possible_fields": [
        "continent", "continentCode", "country", "countryCode", "region", "regionName", "city",
        "district", "zip", "lat", "lon", "timezone", "offset", "currency", "isp", "org", "as",
        "asname", "reverse", "mobile", "proxy", "hosting", "query"
    ],
    "default_fields": [
        "country",
        "countryCode",
        "region",
        "regionName",
        "city",
        "zip",
        "lat",
        "lon",
        "timezone",
        "isp",
        "org",
        "as",
        "query"
    ]
}

CATEGORIES = {
    "Location": ["continent", "continentCode", "country", "countryCode", "region", "regionName", "city", "district", "zip", "lat", "lon", "timezone", "offset"],
    "Network": ["isp", "org", "as", "asname", "reverse"],
    "Details": ["currency", "mobile", "proxy", "hosting"]
}

def get_config_dir():
    """Returns the path to the configuration directory depending on the OS."""
    if sys.platform == "win32":
        return os.path.join(os.getenv('LOCALAPPDATA'), 'whatsip')
    else:
        return os.path.join(os.path.expanduser('~'), '.config', 'whatsip')

def load_config(config_path, console):
    config_dir = os.path.dirname(config_path)
    if config_dir and not os.path.exists(config_dir):
        try:
            os.makedirs(config_dir)
        except OSError:
            console.print(f"[bold red]Warning:[/bold red] Could not create config directory at '[cyan]{config_dir}[/cyan]'.", style="yellow")

    if not os.path.exists(config_path):
        try:
            with open(config_path, 'w', encoding='utf-8') as f:
                json.dump(BASE_DEFAULT_CONFIG, f, indent=4)
            return BASE_DEFAULT_CONFIG
        except IOError:
            console.print(f"[bold red]Warning:[/bold red] Could not create config file at '[cyan]{config_path}[/cyan]'. Using default settings.", style="yellow")
            return BASE_DEFAULT_CONFIG
    
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config_data = json.load(f)
            if "style" not in config_data or "theme" not in config_data:
                console.print(f"[bold yellow]Warning:[/bold yellow] Config file '[cyan]{config_path}[/cyan]' is outdated. Using default settings. Please delete it to regenerate.", style="yellow")
                return BASE_DEFAULT_CONFIG
            return config_data
    except (json.JSONDecodeError, IOError):
        console.print(f"[bold red]Error:[/bold red] Config file '[cyan]{config_path}[/cyan]' is corrupted or unreadable. Using default settings.", style="bold red")
        return BASE_DEFAULT_CONFIG

def get_ip_info(ip_address, fields_to_request=None):
    base_url = f"http://ip-api.com/json/{ip_address}"
    params = {}
    if fields_to_request:
        fields = [f for f in fields_to_request if f not in ["status", "message"]]
        if fields:
            params['fields'] = ",".join(fields)
            
    try:
        response = requests.get(base_url, params=params, timeout=5)
        response.raise_for_status()
        data = response.json()
        # Если IP не был указан, используем полученный IP как отображаемый
        if not ip_address and data.get("status") == "success":
            data["display_ip"] = data.get("query", "Unknown")
        else:
            data["display_ip"] = ip_address or data.get("query", "Unknown")
        return data
    except requests.exceptions.RequestException as e:
        return {"status": "fail", "message": str(e)}

def display_info(data, config, fields_to_show, console):
    if data.get("status") == "fail":
        style = config.get("style", BASE_DEFAULT_CONFIG["style"])
        error_message = data.get("message", "Unknown error")
        console.print(Panel(f"Error: {error_message}", title="[bold red]Request Failed[/bold red]", border_style=style.get("error", "red")))
        sys.exit(1)

    theme = config.get("theme", BASE_DEFAULT_CONFIG["theme"])

    if theme == "dashboard":
        display_dashboard(data, config, fields_to_show, console)
    elif theme == "tree":
        display_tree(data, config, fields_to_show, console)
    elif theme == "minimal":
        display_minimal(data, config, fields_to_show, console)
    elif theme == "json":
        display_json(data, config, fields_to_show, console)
    elif theme == "grid":
        display_grid(data, config, fields_to_show, console)
    elif theme == "markdown":
        display_markdown(data, config, fields_to_show, console)
    elif theme == "compact":
        display_compact(data, config, fields_to_show, console)
    else:
        display_sleek(data, config, fields_to_show, console)

def display_sleek(data, config, fields_to_show, console):
    style = config.get("style", BASE_DEFAULT_CONFIG["style"])

    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    table = Table(box=ROUNDED, show_header=True, header_style=style.get("header", "bold white on blue"))
    table.add_column("Field", style=style.get("field_name", "cyan"), no_wrap=True)
    table.add_column("Value", style=style.get("field_value", "white"))

    for field in current_fields:
        if field in data:
            table.add_row(field.capitalize(), str(data[field]))
    
    panel_title = f"Information for [bold]{data.get('display_ip', 'N/A')}[/bold]"
    console.print(
        Panel(
            table,
            title=panel_title,
            border_style=style.get("panel_border", "blue"),
            expand=False
        )
    )

def make_info_table(data, fields, style):
    table = Table(box=None, show_header=False, padding=(0, 1))
    table.add_column(style=style.get("field_name", "cyan"))
    table.add_column(style=style.get("field_value", "white"))
    for field in fields:
        if field in data:
            table.add_row(f"{field.capitalize()}:", str(data[field]))
    return table

def display_dashboard(data, config, fields_to_show, console):
    style = config.get("style", BASE_DEFAULT_CONFIG["style"])

    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    console.print(Panel(f"[bold]Information for {data.get('display_ip', 'N/A')}[/bold]", expand=False, border_style=style.get("panel_border", "blue")))

    panels = []
    
    processed_fields = set()
    for cat_name, cat_fields in CATEGORIES.items():
        fields_in_cat = [f for f in cat_fields if f in current_fields]
        table = make_info_table(data, fields_in_cat, style)
        if table.row_count > 0:
            panels.append(Panel(table, title=f"[bold]{cat_name}[/bold]", border_style=style.get("panel_border", "blue"), expand=True))
            processed_fields.update(fields_in_cat)

    other_fields = [f for f in current_fields if f not in processed_fields and f not in ['query', 'status']]
    if other_fields:
        other_table = make_info_table(data, other_fields, style)
        if other_table.row_count > 0:
            panels.append(Panel(other_table, title="[bold]Other[/bold]", border_style=style.get("panel_border", "blue"), expand=True))
    
    if panels:
        console.print(Columns(panels, expand=True))

def display_json(data, config, fields_to_show, console):
    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])

    if 'all' in current_fields:
        output_data = {k: v for k, v in data.items() if k != 'status'}
    else:
        output_data = {field: data[field] for field in current_fields if field in data}

    console.print(JSON.from_data(output_data))

def display_compact(data, config, fields_to_show, console):
    style = config.get("style", BASE_DEFAULT_CONFIG["style"])

    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    text = Text()
    query = data.get('display_ip', 'N/A')
    text.append(f"IP: {query}", style="bold")

    for field in current_fields:
        if field in data and field != 'query':
            text.append(" | ", style="dim")
            text.append(f"{field.capitalize()}: ", style=style.get('field_name', 'cyan'))
            text.append(str(data[field]), style=style.get('field_value', 'white'))
            
    console.print(text)

def display_grid(data, config, fields_to_show, console):
    style = config.get("style", BASE_DEFAULT_CONFIG["style"])

    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    table = Table(box=ROUNDED, show_header=True, header_style=style.get("header", "bold white on blue"), title=f"Information for [bold]{data.get('display_ip', 'N/A')}[/bold]")
    table.add_column("Category", style="bold", no_wrap=True)
    table.add_column("Field", style=style.get("field_name", "cyan"))
    table.add_column("Value", style=style.get("field_value", "white"))
    
    processed_fields = set()
    
    for cat_name, cat_fields in CATEGORIES.items():
        fields_to_show_in_cat = [f for f in cat_fields if f in current_fields and f in data]
        if not fields_to_show_in_cat:
            continue
        
        first_in_cat = True
        for field in fields_to_show_in_cat:
            category_cell = f"[{style.get('panel_border', 'blue')}]{cat_name}[/]" if first_in_cat else ""
            table.add_row(category_cell, field.capitalize(), str(data[field]))
            first_in_cat = False
            processed_fields.add(field)

    other_fields = [f for f in current_fields if f not in processed_fields and f not in ['query', 'status'] and f in data]
    if other_fields:
        first_in_cat = True
        for field in other_fields:
            category_cell = f"[{style.get('panel_border', 'blue')}]Other[/]" if first_in_cat else ""
            table.add_row(category_cell, field.capitalize(), str(data[field]))
            first_in_cat = False
            
    console.print(table)

def generate_markdown_string(data, config, fields_to_show):
    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    markdown_string = f"# IP Information for {data.get('display_ip', 'N/A')}\n\n"
    processed_fields = set()

    for cat_name, cat_fields in CATEGORIES.items():
        fields_in_cat = [f for f in cat_fields if f in current_fields and f in data]
        if fields_in_cat:
            markdown_string += f"## {cat_name}\n"
            for field in fields_in_cat:
                markdown_string += f"- **{field.capitalize()}**: {data[field]}\n"
            markdown_string += "\n"
            processed_fields.update(fields_in_cat)

    other_fields = [f for f in current_fields if f not in processed_fields and f not in ['query', 'status'] and f in data]
    if other_fields:
        markdown_string += "## Other\n"
        for field in other_fields:
            markdown_string += f"- **{field.capitalize()}**: {data[field]}\n"
        markdown_string += "\n"
    
    return markdown_string

def display_markdown(data, config, fields_to_show, console):
    markdown_string = generate_markdown_string(data, config, fields_to_show)
    console.print(Markdown(markdown_string))

def display_minimal(data, config, fields_to_show, console):
    style = config.get("style", BASE_DEFAULT_CONFIG["style"])

    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    console.print(f"--- IP Information for [bold]{data.get('display_ip', 'N/A')}[/bold] ---")

    for field in current_fields:
        if field in data:
            console.print(f"[{style.get('field_name', 'cyan')}]{field.capitalize()}:[/] [{style.get('field_value', 'white')}]{data[field]}[/]")


def display_tree(data, config, fields_to_show, console):
    style = config.get("style", BASE_DEFAULT_CONFIG["style"])

    current_fields = fields_to_show
    if not current_fields:
        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in current_fields:
        current_fields = [key for key in data if key != "status"]

    tree = Tree(
        f"IP Information for [bold]{data.get('display_ip', 'N/A')}[/bold]",
        guide_style=style.get("panel_border", "blue")
    )

    field_to_category = {field: cat for cat, fields in CATEGORIES.items() for field in fields}

    grouped_fields = {}
    other_fields = []
    
    for field in current_fields:
        if field not in data:
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
                branch.add(f"[{style.get('field_name', 'cyan')}]{field.capitalize()}:[/] [{style.get('field_value', 'white')}]{data[field]}[/]")

    if other_fields:
        branch = tree.add("[bold]Other[/bold]")
        for field in other_fields:
            branch.add(f"[{style.get('field_name', 'cyan')}]{field.capitalize()}:[/] [{style.get('field_value', 'white')}]{data[field]}[/]")

    console.print(tree)

def save_output(results, filename, config, fields_to_show, console):
    _ , ext = os.path.splitext(filename)
    ext = ext.lower()

    try:
        with open(filename, 'w', encoding='utf-8') as f:
            if ext == '.json':
                output_data = []
                current_fields = fields_to_show
                if not current_fields:
                    current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
                
                for data in results:
                    if 'all' in current_fields:
                        output_data.append({k: v for k, v in data.items() if k != 'status'})
                    else:
                        output_data.append({field: data[field] for field in current_fields if field in data})
                
                if len(output_data) == 1:
                    output_data = output_data[0]

                json.dump(output_data, f, indent=4)

            elif ext == '.md':
                md_content = ""
                for data in results:
                    md_content += generate_markdown_string(data, config, fields_to_show)
                    if len(results) > 1:
                        md_content += "---\n\n"
                f.write(md_content)
            else:
                text_content = ""
                for data in results:
                    text_content += f"--- IP Information for {data.get('display_ip', 'N/A')} ---\n"
                    
                    current_fields = fields_to_show
                    if not current_fields:
                        current_fields = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
                    if 'all' in current_fields:
                        current_fields = [key for key in data if key not in ["status"]]

                    for field in current_fields:
                        if field in data:
                            text_content += f"{field.capitalize()}: {data[field]}\n"
                    text_content += "\n"
                f.write(text_content)
                
        console.print(f"Output saved to [green]{filename}[/green]")
    except IOError as e:
        console.print(f"[bold red]Error:[/bold red] Could not write to file '{filename}'. {e}", style="bold red")

def main():
    parser = argparse.ArgumentParser(
        description="A stylish IP address lookup tool.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('ip', nargs='*', default=[], help='IP address(es) to look up. Your own by default.')
    
    config_dir = get_config_dir()
    default_config_path = os.path.join(config_dir, 'config.json')
    parser.add_argument('--config', default=default_config_path, help=f'Path to a custom config file. Default is {default_config_path}')
    
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-f', '--fields', help='Comma-separated list of fields to display (e.g., "city,isp,lat,lon").')
    group.add_argument('-a', '--all', action='store_true', help='Display all available fields from the API.')

    parser.add_argument('-o', '--output', help='Save output to a file (e.g., output.json, output.md). Format is detected from extension.')

    args = parser.parse_args()
    
    console = Console()
    config = load_config(args.config, console)
    
    fields_to_show = []
    if args.all:
        fields_to_show = ['all']
    elif args.fields:
        fields_to_show = [f.strip() for f in args.fields.split(',')]

    fields_to_request = fields_to_show
    if not fields_to_show:
        fields_to_request = config.get("default_fields", BASE_DEFAULT_CONFIG["default_fields"])
    if 'all' in fields_to_request:
        fields_to_request = BASE_DEFAULT_CONFIG["_all_possible_fields"]

    ips_to_lookup = args.ip if args.ip else ['']
    results = []

    for ip in ips_to_lookup:
        ip_info = get_ip_info(ip, fields_to_request)
        display_info(ip_info, config, fields_to_show, console)
        if ip_info.get("status") == "success":
             results.append(ip_info)
        
        if len(ips_to_lookup) > 1 and ip != ips_to_lookup[-1]:
            console.print()

    if args.output and results:
        save_output(results, args.output, config, fields_to_show, console)

if __name__ == "__main__":
    main()