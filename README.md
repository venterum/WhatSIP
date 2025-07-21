# WhatSIP

[🇷🇺 На русском языке](README_RU.md)

A stylish command-line utility for IP address lookups.

## Usage

### Linux / macOS

```bash
# Installation
git clone https://github.com/venterum/WhatSIP.git
cd WhatSIP
chmod +x install.sh
./install.sh

# Or just install everything in one command:
git clone https://github.com/venterum/WhatSIP.git && cd WhatSIP && chmod +x install.sh && ./install.sh

# Usage (in a new terminal)
whatsip 8.8.8.8
```
### Windows (PowerShell)

```powershell
# First-time script execution might require changing the execution policy.
# Run PowerShell as Administrator and execute:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Installation (in regular PowerShell):
git clone https://github.com/venterum/WhatSIP.git
cd WhatSIP
.\install.ps1

# Or install everything in one command:
git clone https://github.com/venterum/WhatSIP.git && cd WhatSIP && .\install.ps1

# Usage (in a new PowerShell or CMD terminal):
whatsip 8.8.8.8
```

The default theme can be changed in the `config.json` file stored in the `/Appdata/Local/whatsip`.

## Display Themes

Examples for the command `whatsip 8.8.8.8 -f country,city,isp,query`.

### `sleek` (default)
Elegant panel with a table.

```text
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

---

### `dashboard`
The data is grouped to several panels.

```text
┌─ Information for 8.8.8.8 ──────────────────────────────────┐
│                                                            │
└────────────────────────────────────────────────────────────┘
┌─ Location ───────────────┐ ┌─ Network ──────────────┐
│ Country:   United States │ │ Isp:   Google LLC       │
│ City:      Mountain View │ │ Query: 8.8.8.8          │
└──────────────────────────┘ └─────────────────────────┘
```

---

### `grid`
A table with categories.

```text
┌───────── Information for 8.8.8.8 ──────────┐
│ Category │ Field   │ Value                 │
├──────────┼─────────┼───────────────────────┤
│ Location │ Country │ United States         │
│          │ City    │ Mountain View         │
│ Network  │ Isp     │ Google LLC            │
│ Other    │ Query   │ 8.8.8.8               │
└──────────┴─────────┴───────────────────────┘
```

---

### `tree`
Tree-like.

```text
IP Information for 8.8.8.8
├── Location
│   ├── Country: United States
│   └── City: Mountain View
├── Network
│   └── Isp: Google LLC
└── Other
    └── Query: 8.8.8.8
```

---

### `minimal`
"Key: String".

```text
--- IP Information for 8.8.8.8 ---
Country: United States
City: Mountain View
Isp: Google LLC
Query: 8.8.8.8
```

---

### `compact`
Everything in one line.

```text
IP: 8.8.8.8 | Country: United States | City: Mountain View | Isp: Google LLC
```

---

### `json`
JSON output.

```json
{
    "country": "United States",
    "city": "Mountain View",
    "isp": "Google LLC",
    "query": "8.8.8.8"
}
```

---

### `markdown`
Markdown output.

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
