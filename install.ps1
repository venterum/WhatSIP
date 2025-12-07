Clear-Host
$header = @"
 ___       __   ___  ___  ________  _________  ________  ___  ________   
|\  \     |\  \|\  \|\  \|\   __  \|\___   ___\\   ____\|\  \|\   __  \  
\ \  \    \ \  \ \  \\\  \ \  \|\  \|___ \  \_\ \  \___|\ \  \ \  \|\  \ 
 \ \  \  __\ \  \ \   __  \ \   __  \   \ \  \ \ \_____  \ \  \ \   ____\
  \ \  \|\__\_\  \ \  \ \  \ \  \ \  \   \ \  \ \|____|\  \ \  \ \  \___|
   \ \____________\ \__\ \__\ \__\ \__\   \ \__\  ____\_\  \ \__\ \__\   
    \|____________|\|__|\|__|\|__|\|__|    \|__| |\_________\|__|\|__|   
                                                 \|_________|                                                                         
"@
Write-Host $header -ForegroundColor Cyan
Write-Host "         WhatSIP Installation / Установка WhatSIP" -ForegroundColor Green
Write-Host

Write-Host "`nSelect language / Выберите язык:" -ForegroundColor Yellow
Write-Host "  1) " -NoNewline; Write-Host "English" -ForegroundColor White -BackgroundColor DarkGreen
Write-Host "  2) " -NoNewline; Write-Host "Русский" -ForegroundColor White -BackgroundColor DarkGreen

$langChoice = Read-Host -Prompt "Choose option / Выберите вариант [1]"
if ([string]::IsNullOrWhiteSpace($langChoice)) { $langChoice = "1" }

switch ($langChoice) {
    "2" {
        $LANG = @{
            STEP1 = "Шаг 1: Проверка системы"
            STEP2 = "Шаг 2: Выбор имени команды"
            STEP3 = "Шаг 3: Установка"
            STEP4 = "Шаг 4: Настройка окружения"
            SELECT_NAME = "Как вы хотите называть утилиту?"
            RECOMMENDED = "(рекомендуется)"
            SHORT = "(короткий вариант)"
            CUSTOM = "Своё имя"
            FILES_NOT_FOUND = "Ошибка: Не найдены 'main.py' или 'requirements.txt'. Убедитесь, что вы запускаете скрипт из корневой директории проекта."
            FILES_FOUND = "✓ Файлы проекта найдены."
            PYTHON_NOT_FOUND = "Ошибка: Python не найден в PATH. Пожалуйста, установите Python с python.org"
            PYTHON_FOUND = "✓ Python 3 найден."
            VENV_NOT_FOUND = "Ошибка: Модуль 'venv' для Python не найден. Переустановите Python с включенным компонентом 'venv'."
            VENV_FOUND = "✓ Модуль 'venv' найден."
            EMPTY_NAME = "Имя не может быть пустым. Используем 'whatsip'."
            NAME_SELECTED = "Выбрано имя:"
            CREATE_ENV = "Создание окружения в"
            INSTALLING_DEPS = "Установка зависимостей (это может занять некоторое время)..."
            DEPS_ERROR = "Ошибка: Не удалось установить зависимости."
            DEPS_INSTALLED = "✓ Зависимости установлены."
            CREATING_LAUNCHER = "Создание лаунчера в"
            LAUNCHER_CREATED = "✓ Лаунчер создан."
            PATH_ADDED = "✓ Директория добавлена в PATH:"
            PATH_EXISTS = "Директория уже в PATH:"
            CONFIG_COPIED = "✓ Локальная конфигурация скопирована."
            INSTALL_COMPLETE = "✅ Установка завершена!"
            CMD_INSTALLED = "Команда была успешно установлена."
            RESTART_NEEDED = "ЧТОБЫ НАЧАТЬ, ПЕРЕЗАПУСТИТЕ ВАШ ТЕРМИНАЛ!"
            EXAMPLE = "Пример:"
            UNINSTALL = "Удаление: Удалите директории"
            ENTER_NAME = "Введите желаемое имя команды"
            SELECT_OPTION = "Выберите вариант"
        }
    }
    default {
        $LANG = @{
            STEP1 = "Step 1: System Check"
            STEP2 = "Step 2: Command Name Selection"
            STEP3 = "Step 3: Installation"
            STEP4 = "Step 4: Environment Setup"
            SELECT_NAME = "How would you like to name the utility?"
            RECOMMENDED = "(recommended)"
            SHORT = "(short version)"
            CUSTOM = "Custom name"
            FILES_NOT_FOUND = "Error: 'main.py' or 'requirements.txt' not found. Make sure you're running the script from the project root directory."
            FILES_FOUND = "✓ Project files found."
            PYTHON_NOT_FOUND = "Error: Python not found in PATH. Please install Python from python.org"
            PYTHON_FOUND = "✓ Python 3 found."
            VENV_NOT_FOUND = "Error: Python 'venv' module not found. Reinstall Python with 'venv' component enabled."
            VENV_FOUND = "✓ Module 'venv' found."
            EMPTY_NAME = "Name cannot be empty. Using 'whatsip'."
            NAME_SELECTED = "Selected name:"
            CREATE_ENV = "Creating environment in"
            INSTALLING_DEPS = "Installing dependencies (this might take a while)..."
            DEPS_ERROR = "Error: Failed to install dependencies."
            DEPS_INSTALLED = "✓ Dependencies installed."
            CREATING_LAUNCHER = "Creating launcher in"
            LAUNCHER_CREATED = "✓ Launcher created."
            PATH_ADDED = "✓ Directory added to PATH:"
            PATH_EXISTS = "Directory already in PATH:"
            CONFIG_COPIED = "✓ Local configuration copied."
            INSTALL_COMPLETE = "✅ Installation complete!"
            CMD_INSTALLED = "Command has been successfully installed."
            RESTART_NEEDED = "TO START USING, RESTART YOUR TERMINAL!"
            EXAMPLE = "Example:"
            UNINSTALL = "To uninstall: Remove directories"
            ENTER_NAME = "Enter desired command name"
            SELECT_OPTION = "Choose option"
        }
    }
}

Write-Host "`n---[ $($LANG.STEP1) ]---" -ForegroundColor Yellow
if (-not (Test-Path "main.py") -or -not (Test-Path "requirements.txt")) {
    Write-Host $LANG.FILES_NOT_FOUND -ForegroundColor Red
    exit 1
}
Write-Host $LANG.FILES_FOUND

$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host $LANG.PYTHON_NOT_FOUND -ForegroundColor Red
    exit 1
}
Write-Host $LANG.PYTHON_FOUND

try { & $pythonPath.Source -m venv --help > $null } catch {
    Write-Host $LANG.VENV_NOT_FOUND -ForegroundColor Red
    exit 1
}
Write-Host $LANG.VENV_FOUND

Write-Host "`n---[ $($LANG.STEP2) ]---" -ForegroundColor Yellow
Write-Host "$($LANG.SELECT_NAME)`n"
Write-Host "  1) " -NoNewline; Write-Host "whatsip" -ForegroundColor White -BackgroundColor DarkGreen -NoNewline; Write-Host " $($LANG.RECOMMENDED)"
Write-Host "  2) " -NoNewline; Write-Host "ws" -ForegroundColor White -BackgroundColor DarkGreen -NoNewline; Write-Host "      $($LANG.SHORT)"
Write-Host "  3) $($LANG.CUSTOM)"
Write-Host

$choice = Read-Host -Prompt "$($LANG.SELECT_OPTION) [1]"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

switch ($choice) {
    "2" { $commandName = "ws" }
    "3" { 
        $customName = Read-Host $LANG.ENTER_NAME
        if ([string]::IsNullOrWhiteSpace($customName)) {
            Write-Host $LANG.EMPTY_NAME -ForegroundColor Yellow
            $commandName = "whatsip"
        } else {
            $commandName = $customName
        }
    }
    default { $commandName = "whatsip" }
}
Write-Host "$($LANG.NAME_SELECTED) " -NoNewline; Write-Host $commandName -ForegroundColor Green

Write-Host "`n---[ $($LANG.STEP3) ]---" -ForegroundColor Yellow
$appDir = Join-Path $env:LOCALAPPDATA "whatsip"
Write-Host "$($LANG.CREATE_ENV) '$appDir'..."
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }
New-Item -ItemType Directory -Force $appDir | Out-Null
& $pythonPath.Source -m venv "$appDir\venv"

Write-Host $LANG.INSTALLING_DEPS
$pipPath = Join-Path $appDir "venv\Scripts\pip.exe"
& $pipPath install --upgrade pip --quiet
& $pipPath install -r requirements.txt --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host $LANG.DEPS_ERROR -ForegroundColor Red; exit 1
}
Write-Host $LANG.DEPS_INSTALLED

Copy-Item -Path @("main.py", "api.py", "config.py", "display.py") -Destination $appDir

$scriptsDir = Join-Path $env:LOCALAPPDATA "Scripts"
New-Item -ItemType Directory -Force $scriptsDir | Out-Null
$launcherPath = Join-Path $scriptsDir "$commandName.bat"
Write-Host "$($LANG.CREATING_LAUNCHER) '$launcherPath'..."
$launcherContent = @"
@echo off
setlocal
set "APP_HOME=%LOCALAPPDATA%\whatsip"
"%APP_HOME%\venv\Scripts\python.exe" "%APP_HOME%\main.py" %*
endlocal
"@
Set-Content -Path $launcherPath -Value $launcherContent
Write-Host $LANG.LAUNCHER_CREATED

Write-Host "`n---[ $($LANG.STEP4) ]---" -ForegroundColor Yellow
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($userPath -split ';' -contains $scriptsDir)) {
    [System.Environment]::SetEnvironmentVariable("Path", "$userPath;$scriptsDir", "User")
    Write-Host "$($LANG.PATH_ADDED) '$scriptsDir'"
} else {
    Write-Host "$($LANG.PATH_EXISTS) '$scriptsDir'"
}

$configFile = Join-Path $appDir "config.json"
if ((Test-Path "config.json") -and (-not (Test-Path $configFile))) {
    Copy-Item "config.json" -Destination $configFile
    Write-Host $LANG.CONFIG_COPIED
}

Write-Host "`n-----------------------------------------------------" -ForegroundColor DarkGray
Write-Host $LANG.INSTALL_COMPLETE -ForegroundColor Green
Write-Host "$($LANG.CMD_INSTALLED) '$commandName'"
Write-Host $LANG.RESTART_NEEDED -ForegroundColor Yellow
Write-Host
Write-Host "$($LANG.EXAMPLE) " -NoNewline; Write-Host "$commandName 8.8.8.8" -ForegroundColor Cyan
Write-Host "$($LANG.UNINSTALL) '$appDir' and '$launcherPath'" -ForegroundColor DarkGray
Write-Host "-----------------------------------------------------" -ForegroundColor DarkGray