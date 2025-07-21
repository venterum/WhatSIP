# Установщик WhatSIP для Windows PowerShell

# --- Красивый заголовок ---
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
Write-Host "         Установка WhatSIP v1.0" -ForegroundColor Green
Write-Host


# --- Шаг 1: Проверка системы ---
Write-Host "`n---[ Шаг 1: Проверка системы ]---" -ForegroundColor Yellow
if (-not (Test-Path "main.py") -or -not (Test-Path "requirements.txt")) {
    Write-Host "Ошибка: Не найдены 'main.py' или 'requirements.txt'." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Файлы проекта найдены."

$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host "Ошибка: Python не найден в PATH." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Python 3 найден."

try { & $pythonPath.Source -m venv --help > $null } catch {
    Write-Host "Ошибка: Модуль 'venv' для Python не найден." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Модуль 'venv' найден."


# --- Шаг 2: Выбор имени команды ---
Write-Host "`n---[ Шаг 2: Выбор имени команды ]---" -ForegroundColor Yellow
Write-Host "Как вы хотите называть утилиту?`n"
Write-Host "  1) " -NoNewline; Write-Host "whatsip" -ForegroundColor White -BackgroundColor DarkGreen -NoNewline; Write-Host " (рекомендуется)"
Write-Host "  2) " -NoNewline; Write-Host "ws" -ForegroundColor White -BackgroundColor DarkGreen -NoNewline; Write-Host "      (короткий вариант)"
Write-Host "  3) Своё имя"
Write-Host

$choice = Read-Host -Prompt "Выберите вариант [1]"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

switch ($choice) {
    "2" { $commandName = "ws" }
    "3" { 
        $customName = Read-Host "Введите желаемое имя команды"
        if ([string]::IsNullOrWhiteSpace($customName)) {
            Write-Host "Имя не может быть пустым. Используем 'whatsip'." -ForegroundColor Yellow
            $commandName = "whatsip"
        } else {
            $commandName = $customName
        }
    }
    default { $commandName = "whatsip" }
}
Write-Host "Выбрано имя: " -NoNewline; Write-Host $commandName -ForegroundColor Green


# --- Шаг 3: Установка ---
Write-Host "`n---[ Шаг 3: Установка ]---" -ForegroundColor Yellow
$appDir = Join-Path $env:LOCALAPPDATA "whatsip"
Write-Host "Создание окружения в '$appDir'..."
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }
New-Item -ItemType Directory -Force $appDir | Out-Null
& $pythonPath.Source -m venv "$appDir\venv"

Write-Host "Установка зависимостей (это может занять некоторое время)..."
$pipPath = Join-Path $appDir "venv\Scripts\pip.exe"
& $pipPath install --upgrade pip --quiet
& $pipPath install -r requirements.txt --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка: Не удалось установить зависимости." -ForegroundColor Red; exit 1
}
Write-Host "✓ Зависимости установлены."

Copy-Item "main.py" -Destination $appDir

$scriptsDir = Join-Path $env:LOCALAPPDATA "Scripts"
New-Item -ItemType Directory -Force $scriptsDir | Out-Null
$launcherPath = Join-Path $scriptsDir "$commandName.bat"
Write-Host "Создание лаунчера в '$launcherPath'..."
$launcherContent = @"
@echo off
setlocal
set "APP_HOME=%LOCALAPPDATA%\whatsip"
"%APP_HOME%\venv\Scripts\python.exe" "%APP_HOME%\main.py" %*
endlocal
"@
Set-Content -Path $launcherPath -Value $launcherContent
Write-Host "✓ Лаунчер создан."


# --- Шаг 4: Настройка окружения ---
Write-Host "`n---[ Шаг 4: Настройка окружения ]---" -ForegroundColor Yellow
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($userPath -split ';' -contains $scriptsDir)) {
    [System.Environment]::SetEnvironmentVariable("Path", "$userPath;$scriptsDir", "User")
    Write-Host "✓ Директория '$scriptsDir' добавлена в PATH."
} else {
    Write-Host "Директория '$scriptsDir' уже в PATH."
}

$configFile = Join-Path $appDir "config.json"
if ((Test-Path "config.json") -and (-not (Test-Path $configFile))) {
    Copy-Item "config.json" -Destination $configFile
    Write-Host "✓ Локальная конфигурация скопирована."
}


# --- Завершение ---
Write-Host "`n-----------------------------------------------------" -ForegroundColor DarkGray
Write-Host "✅ Установка завершена!" -ForegroundColor Green
Write-Host "Команда '$commandName' была успешно установлена."
Write-Host "ЧТОБЫ НАЧАТЬ, ПЕРЕЗАПУСТИТЕ ВАШ ТЕРМИНАЛ!" -ForegroundColor Yellow
Write-Host
Write-Host "Пример: " -NoNewline; Write-Host "$commandName 8.8.8.8" -ForegroundColor Cyan
Write-Host "Удаление: Удалите директории '$appDir' и '$launcherPath'" -ForegroundColor DarkGray
Write-Host "-----------------------------------------------------" -ForegroundColor DarkGray