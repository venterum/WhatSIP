# Установщик WhatSIP для Windows PowerShell

Write-Host "Установка WhatSIP" -ForegroundColor Yellow
Write-Host "================="
Write-Host

# --- Проверки перед установкой ---
if (-not (Test-Path "main.py") -or -not (Test-Path "requirements.txt")) {
    Write-Host "Ошибка: Не найдены 'main.py' или 'requirements.txt'." -ForegroundColor Red
    Write-Host "Убедитесь, что вы запускаете скрипт из корневой директории проекта." -ForegroundColor Red
    exit 1
}

Write-Host "Проверка наличия Python..."
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host "Ошибка: Python не найден в вашем PATH." -ForegroundColor Red
    Write-Host "Пожалуйста, установите Python 3 с https://python.org и убедитесь, что добавили его в PATH." -ForegroundColor Red
    exit 1
}

try {
    & $pythonPath.Source -m venv --help > $null
} catch {
    Write-Host "Ошибка: Модуль 'venv' для Python не найден." -ForegroundColor Red
    Write-Host "Пожалуйста, переустановите Python, убедившись, что компонент 'venv' включен." -ForegroundColor Red
    exit 1
}

# --- Выбор имени команды ---
Write-Host
$nameChoice = Read-Host @"
Какую команду для вызова вы хотите использовать?
1) whatsip (рекомендуется)
2) ws
3) Своё имя
Выберите вариант [1-3]
"@

switch ($nameChoice) {
    "1" { $commandName = "whatsip" }
    "2" { $commandName = "ws" }
    "3" { 
        $customName = Read-Host "Введите желаемое имя команды"
        if ([string]::IsNullOrWhiteSpace($customName)) {
            Write-Host "Имя не может быть пустым. Используем 'whatsip'."
            $commandName = "whatsip"
        } else {
            $commandName = $customName
        }
    }
    default {
        Write-Host "Неверный выбор. Используем имя 'whatsip'."
        $commandName = "whatsip"
    }
}

# --- Установка ---
$appDir = Join-Path $env:LOCALAPPDATA "whatsip"
Write-Host
Write-Host "Создание изолированного окружения в '$appDir'..." -ForegroundColor Green
if (Test-Path $appDir) {
    Remove-Item -Recurse -Force $appDir
}
New-Item -ItemType Directory -Force $appDir | Out-Null

& $pythonPath.Source -m venv "$appDir\venv"

Write-Host "Установка зависимостей (requests, rich)..." -ForegroundColor Green
$pipPath = Join-Path $appDir "venv\Scripts\pip.exe"
& $pipPath install --upgrade pip > $null
& $pipPath install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка: Не удалось установить зависимости." -ForegroundColor Red
    exit 1
}

Copy-Item "main.py" -Destination $appDir

# Создаем BAT-лаунчер для совместимости с CMD и PowerShell
$scriptsDir = Join-Path $env:LOCALAPPDATA "Scripts"
New-Item -ItemType Directory -Force $scriptsDir | Out-Null
$launcherPath = Join-Path $scriptsDir "$commandName.bat"

Write-Host "Создание лаунчера в '$launcherPath'..." -ForegroundColor Green
$launcherContent = @"
@echo off
setlocal
set "APP_HOME=%LOCALAPPDATA%\whatsip"
"%APP_HOME%\venv\Scripts\python.exe" "%APP_HOME%\main.py" %*
endlocal
"@
Set-Content -Path $launcherPath -Value $launcherContent

# --- Настройка PATH ---
Write-Host "Добавление '$scriptsDir' в системный PATH..." -ForegroundColor Green
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($userPath -split ';' -contains $scriptsDir)) {
    $newPath = "$userPath;$scriptsDir"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Директория '$scriptsDir' была добавлена в ваш PATH." -ForegroundColor Yellow
    Write-Host "Изменения вступят в силу в НОВОМ окне терминала." -ForegroundColor Yellow
} else {
    Write-Host "Директория '$scriptsDir' уже находится в вашем PATH."
}

# --- Настройка конфига ---
$configFile = Join-Path $appDir "config.json"
Write-Host
Write-Host "Настройка конфигурационного файла..." -ForegroundColor Green
if ((Test-Path "config.json") -and (-not (Test-Path $configFile))) {
    Copy-Item "config.json" -Destination $configFile
    Write-Host "Локальная конфигурация скопирована в '$configFile'."
}

# --- Завершение ---
Write-Host
Write-Host "Установка завершена!" -ForegroundColor Cyan
Write-Host "Команда '$commandName' была установлена."
Write-Host "ПОЖАЛУЙСТА, ПЕРЕЗАПУСТИТЕ ВАШ ТЕРМИНАЛ (PowerShell, CMD и др.), чтобы изменения вступили в силу." -ForegroundColor Yellow
Write-Host
Write-Host "Пример использования (в новом терминале): $commandName 8.8.8.8" -ForegroundColor Cyan
Write-Host "Для удаления утилиты просто удалите директорию '$appDir' и файл '$launcherPath'." -ForegroundColor Cyan 