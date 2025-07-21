# WhatSIP

Стильная утилита командной строки для поиска информации о IP-адресах.

## Использование

### Linux / macOS

```bash
# Установка
chmod +x install.sh
./install.sh

# Использование (в новом терминале)
whatsip 8.8.8.8
```

### Windows (PowerShell)

```powershell
# При первом запуске скриптов может потребоваться изменить политику выполнения.
# Запустите PowerShell от имени администратора и выполните:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Установка (в обычном PowerShell):
.\install.ps1

# Использование (в новом терминале PowerShell или CMD):
whatsip 8.8.8.8
```

Тема по умолчанию изменяется в файле `config.json`.

## Темы оформления

Примеры для команды `python main.py 8.8.8.8 -f country,city,isp,query`.

---

### `sleek` (по умолчанию)
Элегантная панель с таблицей.

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
Данные сгруппированы в несколько панелей.

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
Таблица с категориями.

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
Иерархическое представление данных.

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
Простой вывод "Ключ: Значение".

```text
--- IP Information for 8.8.8.8 ---
Country: United States
City: Mountain View
Isp: Google LLC
Query: 8.8.8.8
```

---

### `compact`
Вся информация в одной строке.

```text
IP: 8.8.8.8 | Country: United States | City: Mountain View | Isp: Google LLC
```

---

### `json`
Вывод в формате JSON.

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
Вывод в формате Markdown.

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
