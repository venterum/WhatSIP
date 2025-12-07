# WhatSIP

[🇷🇺 Версия на русском](README_RU.md)

A stylish and feature-rich command-line utility for IP address lookups.

## Features

- **Detailed IP Information**: Get location, network, and other details for any IP address.
- **Multiple Output Themes**: Choose from 8 stylish themes to display information.
- **Customizable Fields**: Select exactly which fields you want to see.
- **Save to File**: Export results to JSON or Markdown files.
- **Easy Installation**: Simple installation scripts for Linux, macOS, and Windows.
- **Configurable**: Customize default theme, fields, and colors.

## Installation

**Prerequisites:**
- [Git](https://git-scm.com/downloads)
- [Python 3](https://www.python.org/downloads/)

---

### Linux / macOS

The script will install the `whatsip` command to `~/.local/bin`.

```bash
# Clone the repository and run the installer
git clone https://github.com/venterum/WhatSIP.git
cd WhatSIP
chmod +x install.sh
./install.sh

# The script will ask for your preferred command name (e.g., whatsip or ws)
# After installation, restart your terminal or source your shell's config file
# e.g., source ~/.bashrc or source ~/.zshrc
```

---

### Windows (using PowerShell)

The script will install the command to `%LOCALAPPDATA%\Scripts`.

```powershell
# If this is your first time running a local script, you may need to allow it.
# (Run this once in an Administrator PowerShell)
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Clone the repository and run the installer in a regular PowerShell window
git clone https://github.com/venterum/WhatSIP.git
cd WhatSIP
.\install.ps1

# The script will ask for your preferred command name (e.g., whatsip or ws)
# After installation, restart your terminal for the PATH changes to take effect.
```

## Usage

```
whatsip [IP_ADDRESS] [OPTIONS]
```

### Arguments

| Argument          | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `IP_ADDRESS`      | The IP address to look up. If omitted, it will use your own public IP.      |
| `-f, --fields`    | Specify which fields to display, separated by commas (e.g., `country,city`). |
| `--all`           | Display all available fields.                                               |
| `-o, --output`    | Save the output to a file (e.g., `result.json` or `result.md`).             |
| `-c, --config`    | Specify a path to a custom config file.                                     |
| `-h, --help`      | Show the help message.                                                      |

### Examples

```bash
# Look up your own IP address
whatsip

# Look up a specific IP
whatsip 8.8.8.8

# Look up multiple IPs
whatsip 8.8.8.8 1.1.1.1

# Show only the country, city, and ISP
whatsip 8.8.8.8 -f country,city,isp

# Save the full output for an IP to a markdown file
whatsip 8.8.8.8 --all -o report.md
```

## Configuration

The configuration is stored in a `config.json` file. The script will create a default one for you.

- **Linux/macOS**: `~/.config/whatsip/config.json`
- **Windows**: `%LOCALAPPDATA%\whatsip\config.json`

You can customize the following settings:
- `theme`: The default display theme to use.
- `default_fields`: An array of fields to show by default.
- `style`: An object to customize the colors for different UI elements.

## Output Themes

You can set the default theme in the `config.json` file. Eight themes are available:

<details>
<summary><b>sleek</b> (default) - An elegant panel with a table.</summary>

```
┌─ Information for 8.8.8.8 ───────────┐
│ ┏━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┓     │
│ ┃ Field   ┃ Value             ┃     │
│ ┡━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━┩     │
│ │ Country │ United States     │     │
│ │ City    │ Mountain View     │     │
│ │ Isp     │ Google LLC        │     │
│ │ Query   │ 8.8.8.8           │     │
│ └─────────┴───────────────────┘     │
└─────────────────────────────────────┘
```
</details>

<details>
<summary><b>dashboard</b> - Data is grouped into several panels.</summary>

```
┌─ Information for 8.8.8.8 ──────────────────────────────────┐
│                                                            │
└────────────────────────────────────────────────────────────┘
┌─ Location ───────────────┐ ┌─ Network ──────────────┐
│ Country:   United States │ │ Isp:   Google LLC       │
│ City:      Mountain View │ │ Query: 8.8.8.8          │
└──────────────────────────┘ └─────────────────────────┘
```
</details>

<details>
<summary><b>grid</b> - A single table with categories.</summary>

```
┌───────── Information for 8.8.8.8 ──────────┐
│ Category │ Field   │ Value                 │
├──────────┼─────────┼───────────────────────┤
│ Location │ Country │ United States         │
│          │ City    │ Mountain View         │
│ Network  │ Isp     │ Google LLC            │
│ Other    │ Query   │ 8.8.8.8               │
└──────────┴─────────┴───────────────────────┘
```
</details>

<details>
<summary><b>tree</b> - A collapsible, tree-like structure.</summary>

```
IP Information for 8.8.8.8
├── Location
│   ├── Country: United States
│   └── City: Mountain View
├── Network
│   └── Isp: Google LLC
└── Other
    └── Query: 8.8.8.8
```
</details>

<details>
<summary><b>minimal</b> - Simple key-value pairs.</summary>

```
--- IP Information for 8.8.8.8 ---
Country: United States
City: Mountain View
Isp: Google LLC
Query: 8.8.8.8
```
</details>

<details>
<summary><b>compact</b> - All information on a single line.</summary>

```
IP: 8.8.8.8 | Country: United States | City: Mountain View | Isp: Google LLC
```
</details>

<details>
<summary><b>json</b> - Raw JSON output, useful for scripting.</summary>

```json
{
    "country": "United States",
    "city": "Mountain View",
    "isp": "Google LLC",
    "query": "8.8.8.8"
}
```
</details>

<details>
<summary><b>markdown</b> - Formatted for markdown documents.</summary>

```markdown
# IP Information for 8.8.8.8

## Location
- **Country**: United States
- **City**: Mountain View

## Network
- **Isp**: Google LLC

## Other
- **Query**: 8.8.8.8
```
</details>