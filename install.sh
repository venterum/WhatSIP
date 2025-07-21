#!/bin/bash

# --- Цвета и стили ---
C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'

clear

# --- Красивый заголовок ---
echo -e "${C_BLUE}${C_BOLD}"
echo ' ___       __   ___  ___  ________  _________  ________  ___  ________   '
echo '|\  \     |\  \|\  \|\  \|\   __  \|\___   ___\\   ____\|\  \|\   __  \  '
echo '\ \  \    \ \  \ \  \\\  \ \  \|\  \|___ \  \_\ \  \___|\ \  \ \  \|\  \ '
echo ' \ \  \  __\ \  \ \   __  \ \   __  \   \ \  \ \ \_____  \ \  \ \   ____\'
echo '  \ \  \|\__\_\  \ \  \ \  \ \  \ \  \   \ \  \ \|____|\  \ \  \ \  \___|'
echo '   \ \____________\ \__\ \__\ \__\ \__\   \ \__\  ____\_\  \ \__\ \__\   '
echo '    \|____________|\|__|\|__|\|__|\|__|    \|__| |\_________\|__|\|__|   '
echo '                                                 \|_________|            '
echo '                                                                         '
echo -e "${C_RESET}"
echo -e "${C_GREEN}         Установка WhatSIP v1.0${C_RESET}"
echo

# --- Шаг 1: Проверка системы ---
echo -e "${C_YELLOW}---[ Шаг 1: Проверка системы ]---${C_RESET}"

if [ ! -f "main.py" ] || [ ! -f "requirements.txt" ]; then
    echo -e "${C_RED}Ошибка: Не найдены 'main.py' или 'requirements.txt'. Убедитесь, что вы запускаете скрипт из корневой директории проекта.${C_RESET}"
    exit 1
fi
echo -e "✓ Файлы проекта найдены."

if ! command -v python3 &> /dev/null; then
    echo -e "${C_RED}Ошибка: Python 3 не найден. Пожалуйста, установите Python 3.${C_RESET}"
    exit 1
fi
echo -e "✓ Python 3 найден."

if ! python3 -c "import venv" &> /dev/null; then
    echo -e "${C_RED}Ошибка: Модуль 'venv' для Python 3 не найден. Пример для Debian/Ubuntu: sudo apt install python3-venv${C_RESET}"
    exit 1
fi
echo -e "✓ Модуль 'venv' найден."


# --- Шаг 2: Выбор имени команды ---
echo -e "\n${C_YELLOW}---[ Шаг 2: Выбор имени команды ]---${C_RESET}"
echo "Как вы хотите называть утилиту?"
echo
echo -e "  ${C_GREEN}1)${C_RESET} ${C_BOLD}whatsip${C_RESET} (рекомендуется)"
echo -e "  ${C_GREEN}2)${C_RESET} ${C_BOLD}ws${C_RESET}       (короткий вариант)"
echo -e "  ${C_GREEN}3)${C_RESET} Своё имя"
echo

read -p "Выберите вариант [1]: " name_choice

case $name_choice in
    2) command_name="ws" ;;
    3)
        read -p "Введите желаемое имя команды: " custom_name
        if [ -z "$custom_name" ]; then
            echo -e "${C_YELLOW}Имя не может быть пустым. Используем 'whatsip'.${C_RESET}"
            command_name="whatsip"
        else
            command_name="$custom_name"
        fi
        ;;
    *) command_name="whatsip" ;;
esac
echo -e "Выбрано имя: ${C_GREEN}${command_name}${C_RESET}"


# --- Шаг 3: Установка ---
echo -e "\n${C_YELLOW}---[ Шаг 3: Установка ]---${C_RESET}"

APP_DIR="$HOME/.local/share/whatsip"
echo -n "Создание окружения в $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"
python3 -m venv "$APP_DIR/venv" &> /dev/null
echo -e " ${C_GREEN}✓${C_RESET}"

echo -n "Установка зависимостей..."
{
    "$APP_DIR/venv/bin/pip" install --upgrade pip &> /dev/null
    "$APP_DIR/venv/bin/pip" install -r requirements.txt &> /dev/null
}
if [ $? -ne 0 ]; then
    echo -e " ${C_RED}✗${C_RESET}"
    echo -e "${C_RED}Ошибка: Не удалось установить зависимости.${C_RESET}"
    exit 1
fi
echo -e " ${C_GREEN}✓${C_RESET}"

cp main.py "$APP_DIR/"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
LAUNCHER_PATH="$INSTALL_DIR/$command_name"

echo -n "Создание лаунчера в $LAUNCHER_PATH..."
cat << EOF > "$LAUNCHER_PATH"
#!/bin/bash
APP_HOME="\$HOME/.local/share/whatsip"
"\$APP_HOME/venv/bin/python" "\$APP_HOME/main.py" "\$@"
EOF
chmod +x "$LAUNCHER_PATH"
echo -e " ${C_GREEN}✓${C_RESET}"


# --- Шаг 4: Настройка окружения ---
echo -e "\n${C_YELLOW}---[ Шаг 4: Настройка окружения ]---${C_RESET}"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    shell_config_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    path_export_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    for config_file in "\${shell_config_files[@]}"; do
        if [ -f "$config_file" ] && ! grep -q "# WhatSIP path" "$config_file"; then
            echo -e "\n# WhatSIP path\n$path_export_line" >> "$config_file"
            echo "Добавлен PATH в $config_file"
        fi
    done
else
    echo "Директория $INSTALL_DIR уже в PATH."
fi

CONFIG_DIR="$HOME/.config/whatsip"
CONFIG_FILE="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"
if [ -f "config.json" ] && [ ! -f "$CONFIG_FILE" ]; then
    cp config.json "$CONFIG_FILE"
    echo "Конфигурация скопирована в $CONFIG_FILE."
else
    echo "Используется существующая или будет создана новая конфигурация."
fi


# --- Завершение ---
echo -e "\n${C_GREEN}✅ Установка завершена!${C_RESET}"
echo -e "Команда '${C_BOLD}${command_name}${C_RESET}' была успешно установлена."
echo -e "${C_YELLOW}Чтобы начать, перезапустите терминал или выполните 'source ~/.bashrc' (или .zshrc).${C_RESET}"
echo
echo -e "Пример: ${C_BOLD}${command_name} 8.8.8.8${C_RESET}"
echo -e "Удаление: rm -rf $APP_DIR $CONFIG_DIR $LAUNCHER_PATH"
