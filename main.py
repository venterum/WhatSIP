import argparse
import json
import os
import sys
import requests
from rich.console import Console
from rich.panel import Panel

from config import BASE_DEFAULT_CONFIG
from display import DisplayManager
from api import IPInfoProvider

def get_config_dir():
    """Returns the path to the configuration directory depending on the OS."""
    if sys.platform == "win32":
        return os.path.join(os.getenv('LOCALAPPDATA'), 'whatsip')
    else:
        return os.path.join(os.path.expanduser('~'), '.config', 'whatsip')

def load_config(config_path, console):
    """
    Loads the configuration from a JSON file.

    Args:
        config_path (str): The path to the configuration file.
        console (Console): The rich console object.

    Returns:
        dict: The configuration dictionary.
    """
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
            user_config = json.load(f)
        
        # Merge user_config with base_config to add new fields without overwriting existing user settings
        config_data = BASE_DEFAULT_CONFIG.copy()
        config_data.update(user_config)

        if "style" not in user_config or "theme" not in user_config:
            console.print(f"[bold yellow]Warning:[/bold yellow] Config file '[cyan]{config_path}[/cyan]' is outdated. Using default settings and regenerating the file.", style="yellow")
            with open(config_path, 'w', encoding='utf-8') as f:
                json.dump(config_data, f, indent=4)

        return config_data
    except (json.JSONDecodeError, IOError):
        console.print(f"[bold red]Error:[/bold red] Config file '[cyan]{config_path}[/cyan]' is corrupted or unreadable. Using default settings.", style="bold red")
        return BASE_DEFAULT_CONFIG

def save_output(results, filename, config, fields_to_show, console):
    """
    Saves the output to a file.

    Args:
        results (list): A list of IP information dictionaries.
        filename (str): The name of the file to save the output to.
        config (dict): The configuration dictionary.
        fields_to_show (list): A list of fields to show in the output.
        console (Console): The rich console object.
    """
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
                    display_manager = DisplayManager(console)
                    display = display_manager.get_display("markdown", config, data, fields_to_show)
                    md_content += display.generate_markdown_string()
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
    """The main function of the program."""
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
    display_manager = DisplayManager(console)
    ip_info_provider = IPInfoProvider()
    
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
        try:
            ip_info = ip_info_provider.get_ip_info(ip, fields_to_request)
            display_manager.display(ip_info, config, fields_to_show)
            if ip_info.get("status") == "success":
                 results.append(ip_info)
        except requests.exceptions.Timeout:
            console.print(Panel("The API did not respond in time.", title="[bold red]Request Timed Out[/bold red]", border_style="red"))
        except requests.exceptions.RequestException as e:
            console.print(Panel(f"Error: {e}", title="[bold red]Request Failed[/bold red]", border_style="red"))
        
        if len(ips_to_lookup) > 1 and ip != ips_to_lookup[-1]:
            console.print()

    if args.output and results:
        save_output(results, args.output, config, fields_to_show, console)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nWork stopped.")
    except Exception as e:
        print(f"\n[bold red]An unexpected error occurred: {e}[/bold red]")