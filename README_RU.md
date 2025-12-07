# WhatSIP

[English version](README.md)

Красивая и многофункциональная утилита для получения информации об IP-адресах.

## Возможности

- **Подробная информация об IP**: Получайте данные о местоположении, сети и другие сведения о своём или любом другом IP-адресе.
- **Множество тем оформления**: Выбирайте из 8 стильных тем для отображения информации.
- **Настраиваемые поля**: Выбирайте, какие именно поля вы хотите видеть.
- **Сохранение в файл**: Экспортируйте результаты в файлы JSON или Markdown.
- **Простая установка**: Удобные скрипты установки для Linux, macOS и Windows.
- **Гибкая настройка**: Настраивайте тему по умолчанию, поля и цвета.

## Установка

**Требования:**
- [Git](https://git-scm.com/downloads)
- [Python 3](https://www.python.org/downloads/)

---

### Linux / macOS

Скрипт установит команду `whatsip` в `~/.local/bin`.

```bash
# Склонируйте репозиторий и запустите установщик
git clone https://github.com/venterum/WhatSIP.git
cd WhatSIP
chmod +x install.sh
./install.sh

# Скрипт предложит выбрать имя для команды (например, whatsip или ws)
# После установки перезапустите терминал или выполните source для вашего конфигурационного файла
# например, source ~/.bashrc или source ~/.zshrc
```

---

### Windows (используя PowerShell)

Скрипт установит команду в `%LOCALAPPDATA%\Scripts`.

```powershell
# Если вы впервые запускаете локальный скрипт, может потребоваться разрешить его выполнение.
# (Выполните один раз в PowerShell от имени администратора)
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Склонируйте репозиторий и запустите установщик в обычном окне PowerShell
git clone https://github.com/venterum/WhatSIP.git
cd WhatSIP
.\install.ps1

# Скрипт предложит выбрать имя для команды (например, whatsip или ws)
# После установки перезапустите терминал, чтобы изменения PATH вступили в силу.
```

## Использование

```
whatsip [IP_АДРЕС] [ОПЦИИ]
```

### Аргументы

| Аргумент          | Описание                                                                    |
|-------------------|-----------------------------------------------------------------------------|
| `IP_АДРЕС`        | IP-адрес для проверки. Если не указан, будет использован ваш публичный IP.   |
| `-f, --fields`    | Указать, какие поля отображать, через запятую (например, `country,city`).   |
| `--all`           | Показать все доступные поля.                                                |
| `-o, --output`    | Сохранить вывод в файл (например, `result.json` или `result.md`).           |
| `-c, --config`    | Указать путь к пользовательскому файлу конфигурации.                        |
| `-h, --help`      | Показать справочное сообщение.                                              |

### Примеры

```bash
# Узнать информацию о собственном IP
whatsip

# Узнать информацию о конкретном IP
whatsip 8.8.8.8

# Узнать информацию о нескольких IP
whatsip 8.8.8.8 1.1.1.1

# Показать только страну, город и провайдера
whatsip 8.8.8.8 -f country,city,isp

# Сохранить полную информацию в файл markdown
whatsip 8.8.8.8 --all -o report.md
```

## Конфигурация

Параметры хранятся в файле `config.json`. Скрипт установки создаст его по умолчанию.

- **Linux/macOS**: `~/.config/whatsip/config.json`
- **Windows**: `%LOCALAPPDATA%\whatsip\config.json`

Вы можете настроить следующие параметры:
- `theme`: тема оформления по умолчанию.
- `default_fields`: массив полей для отображения по умолчанию.
- `style`: объект для настройки цветов различных элементов интерфейса.

## Темы оформления

Вы можете установить тему по умолчанию в файле `config.json`. Доступно 8 тем:

<details>
<summary><b>sleek</b> (по умолчанию) - Элегантная панель с таблицей.</summary>

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
<summary><b>dashboard</b> - Данные сгруппированы в несколько панелей.</summary>

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
<summary><b>grid</b> - Единая таблица с категориями.</summary>

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
<summary><b>tree</b> - Иерархическая, древовидная структура.</summary>

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
<summary><b>minimal</b> - Простые пары "ключ-значение".</summary>

```
--- IP Information for 8.8.8.8 ---
Country: United States
City: Mountain View
Isp: Google LLC
Query: 8.8.8.8
```
</details>

<details>
<summary><b>compact</b> - Вся информация в одной строке.</summary>

```
IP: 8.8.8.8 | Country: United States | City: Mountain View | Isp: Google LLC
```
</details>

<details>
<summary><b>json</b> - "Сырой" вывод в формате JSON, удобен для скриптов.</summary>

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
<summary><b>markdown</b> - Отформатировано для markdown-документов.</summary>

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