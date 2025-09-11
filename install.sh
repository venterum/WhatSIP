#!/bin/bash

C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_DIM='\033[2m'

clear

# ASCII Logo
echo -e "${C_BLUE}${C_BOLD}"
echo ' ___       __   ___  ___  ________  _________  ________  ___  ________   '
echo '|\  \     |\  \|\  \|\  \|\   __  \|\___   ___\\   ____\|\  \|\   __  \  '
echo '\ \  \    \ \  \ \  \\\  \ \  \|\  \|___ \  \_\ \  \___|\ \  \ \  \|\  \ '
echo ' \ \  \  __\ \  \ \   __  \ \   __  \   \ \  \ \ \_____  \ \  \ \   ____\'
echo '  \ \  \|\__\_\  \ \  \ \  \ \  \ \  \   \ \  \ \|____|\  \ \  \ \  \___|'
echo '   \ \____________\ \__\ \__\ \__\ \__\   \ \__\  ____\_\  \ \__\ \__\   '
echo '    \|____________|\|__|\|__|\|__|\|__|    \|__| |\_________\|__|\|__|   '
echo '                                                 \|_________|            '
echo -e "${C_RESET}"
echo -e "${C_GREEN}         WhatSIP Installation / Установка WhatSIP${C_RESET}"
echo

# Выбор языка
echo -e "\n${C_YELLOW}Select language / Выберите язык:${C_RESET}"
echo -e "  ${C_GREEN}1)${C_RESET} ${C_BOLD}English${C_RESET}"
echo -e "  ${C_GREEN}2)${C_RESET} ${C_BOLD}Русский${C_RESET}"
echo

read -p "Choose option / Выберите вариант [1]: " lang_choice

case $lang_choice in
    2)
        declare -A LANG=(
            ["STEP1"]="Шаг 1: Проверка системы"
            ["STEP2"]="Шаг 2: Выбор имени команды"
            ["STEP3"]="Шаг 3: Установка"
            ["STEP4"]="Шаг 4: Настройка окружения"
            ["SELECT_NAME"]="Как вы хотите называть утилиту?"
            ["RECOMMENDED"]="(рекомендуется)"
            ["SHORT"]="(короткий вариант)"
            ["CUSTOM"]="Своё имя"
            ["FILES_NOT_FOUND"]="Ошибка: Не найдены 'main.py' или 'requirements.txt'. Убедитесь, что вы запускаете скрипт из корневой директории проекта."
            ["FILES_FOUND"]="✓ Файлы проекта найдены."
            ["PYTHON_NOT_FOUND"]="Ошибка: Python 3 не найден. Пожалуйста, установите Python 3."
            ["PYTHON_FOUND"]="✓ Python 3 найден."
            ["VENV_NOT_FOUND"]="Ошибка: Модуль 'venv' для Python 3 не найден. Пример для Debian/Ubuntu: sudo apt install python3-venv"
            ["VENV_FOUND"]="✓ Модуль 'venv' найден."
            ["EMPTY_NAME"]="Имя не может быть пустым. Используем 'whatsip'."
            ["NAME_SELECTED"]="Выбрано имя:"
            ["CREATE_ENV"]="Создание окружения в"
            ["INSTALLING_DEPS"]="Установка зависимостей..."
            ["DEPS_ERROR"]="Ошибка: Не удалось установить зависимости."
            ["DEPS_INSTALLED"]="✓ Зависимости установлены."
            ["CREATING_LAUNCHER"]="Создание лаунчера в"
            ["LAUNCHER_CREATED"]="✓ Лаунчер создан."
            ["PATH_ADDED"]="✓ Директория добавлена в PATH:"
            ["PATH_EXISTS"]="Директория уже в PATH:"
            ["CONFIG_COPIED"]="✓ Локальная конфигурация скопирована."
            ["CONFIG_EXISTS"]="Используется существующая или будет создана новая конфигурация."
            ["INSTALL_COMPLETE"]="✅ Установка завершена!"
            ["CMD_INSTALLED"]="Команда была успешно установлена."
            ["RESTART_NEEDED"]="Чтобы начать, перезапустите терминал или выполните 'source ~/.bashrc' (или .zshrc)."
            ["EXAMPLE"]="Пример:"
            ["UNINSTALL"]="Удаление: rm -rf"
            ["ENTER_NAME"]="Введите желаемое имя команды:"
            ["SELECT_OPTION"]="Выберите вариант"
        )
        ;;
    *)
        declare -A LANG=(
            ["STEP1"]="Step 1: System Check"
            ["STEP2"]="Step 2: Command Name Selection"
            ["STEP3"]="Step 3: Installation"
            ["STEP4"]="Step 4: Environment Setup"
            ["SELECT_NAME"]="How would you like to name the utility?"
            ["RECOMMENDED"]="(recommended)"
            ["SHORT"]="(short version)"
            ["CUSTOM"]="Custom name"
            ["FILES_NOT_FOUND"]="Error: 'main.py' or 'requirements.txt' not found. Make sure you're running the script from the project root directory."
            ["FILES_FOUND"]="✓ Project files found."
            ["PYTHON_NOT_FOUND"]="Error: Python 3 not found. Please install Python 3."
            ["PYTHON_FOUND"]="✓ Python 3 found."
            ["VENV_NOT_FOUND"]="Error: Python 'venv' module not found. For Debian/Ubuntu: sudo apt install python3-venv"
            ["VENV_FOUND"]="✓ Module 'venv' found."
            ["EMPTY_NAME"]="Name cannot be empty. Using 'whatsip'."
            ["NAME_SELECTED"]="Selected name:"
            ["CREATE_ENV"]="Creating environment in"
            ["INSTALLING_DEPS"]="Installing dependencies..."
            ["DEPS_ERROR"]="Error: Failed to install dependencies."
            ["DEPS_INSTALLED"]="✓ Dependencies installed."
            ["CREATING_LAUNCHER"]="Creating launcher in"
            ["LAUNCHER_CREATED"]="✓ Launcher created."
            ["PATH_ADDED"]="✓ Directory added to PATH:"
            ["PATH_EXISTS"]="Directory already in PATH:"
            ["CONFIG_COPIED"]="✓ Local configuration copied."
            ["CONFIG_EXISTS"]="Using existing or will create new configuration."
            ["INSTALL_COMPLETE"]="✅ Installation complete!"
            ["CMD_INSTALLED"]="Command has been successfully installed."
            ["RESTART_NEEDED"]="To start using, restart your terminal or run 'source ~/.bashrc' (or .zshrc)."
            ["EXAMPLE"]="Example:"
            ["UNINSTALL"]="To uninstall: rm -rf"
            ["ENTER_NAME"]="Enter desired command name:"
            ["SELECT_OPTION"]="Choose option"
        )
        ;;
esac

echo -e "\n${C_YELLOW}---[ ${LANG[STEP1]} ]---${C_RESET}"

if [ ! -f "main.py" ] || [ ! -f "requirements.txt" ]; then
    echo -e "${C_RED}${LANG[FILES_NOT_FOUND]}${C_RESET}"
    exit 1
fi
echo -e "${LANG[FILES_FOUND]}"

if ! command -v python3 &> /dev/null; then
    echo -e "${C_RED}${LANG[PYTHON_NOT_FOUND]}${C_RESET}"
    exit 1
fi
echo -e "${LANG[PYTHON_FOUND]}"

if ! python3 -c "import venv" &> /dev/null; then
    echo -e "${C_RED}${LANG[VENV_NOT_FOUND]}${C_RESET}"
    exit 1
fi
echo -e "${LANG[VENV_FOUND]}"

echo -e "\n${C_YELLOW}---[ ${LANG[STEP2]} ]---${C_RESET}"
echo -e "${LANG[SELECT_NAME]}"
echo
echo -e "  ${C_GREEN}1)${C_RESET} ${C_BOLD}whatsip${C_RESET} ${LANG[RECOMMENDED]}"
echo -e "  ${C_GREEN}2)${C_RESET} ${C_BOLD}ws${C_RESET}       ${LANG[SHORT]}"
echo -e "  ${C_GREEN}3)${C_RESET} ${LANG[CUSTOM]}"
echo

read -p "${LANG[SELECT_OPTION]} [1]: " name_choice

case $name_choice in
    2) command_name="ws" ;;
    3)
        read -p "${LANG[ENTER_NAME]} " custom_name
        if [ -z "$custom_name" ]; then
            echo -e "${C_YELLOW}${LANG[EMPTY_NAME]}${C_RESET}"
            command_name="whatsip"
        else
            command_name="$custom_name"
        fi
        ;;
    *) command_name="whatsip" ;;
esac
echo -e "${LANG[NAME_SELECTED]} ${C_GREEN}${command_name}${C_RESET}"

echo -e "\n${C_YELLOW}---[ ${LANG[STEP3]} ]---${C_RESET}"

APP_DIR="$HOME/.local/share/whatsip"
echo -n "${LANG[CREATE_ENV]} $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"
python3 -m venv "$APP_DIR/venv" &> /dev/null
echo -e " ${C_GREEN}✓${C_RESET}"

echo -n "${LANG[INSTALLING_DEPS]}"
{
    "$APP_DIR/venv/bin/pip" install --upgrade pip &> /dev/null
    "$APP_DIR/venv/bin/pip" install -r requirements.txt &> /dev/null
}
if [ $? -ne 0 ]; then
    echo -e " ${C_RED}✗${C_RESET}"
    echo -e "${C_RED}${LANG[DEPS_ERROR]}${C_RESET}"
    exit 1
fi
echo -e " ${C_GREEN}✓${C_RESET}"

cp main.py "$APP_DIR/"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
LAUNCHER_PATH="$INSTALL_DIR/$command_name"

echo -n "${LANG[CREATING_LAUNCHER]} $LAUNCHER_PATH..."
cat << EOF > "$LAUNCHER_PATH"
#!/bin/bash
APP_HOME="\$HOME/.local/share/whatsip"
"\$APP_HOME/venv/bin/python" "\$APP_HOME/main.py" "\$@"
EOF
chmod +x "$LAUNCHER_PATH"
echo -e " ${C_GREEN}✓${C_RESET}"

echo -e "\n${C_YELLOW}---[ ${LANG[STEP4]} ]---${C_RESET}"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    shell_config_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.config/fish/config.fish")
    path_export_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    for config_file in "${shell_config_files[@]}"; do
        if [ -f "$config_file" ] && ! grep -q "# WhatSIP path" "$config_file"; then
            echo -e "\n# WhatSIP path\n$path_export_line" >> "$config_file"
            echo -e "${LANG[PATH_ADDED]} $config_file"
        fi
    done
else
    echo -e "${LANG[PATH_EXISTS]} $INSTALL_DIR"
fi

CONFIG_DIR="$HOME/.config/whatsip"
CONFIG_FILE="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"
if [ -f "config.json" ] && [ ! -f "$CONFIG_FILE" ]; then
    cp config.json "$CONFIG_FILE"
    echo -e "${LANG[CONFIG_COPIED]}"
else
    echo -e "${LANG[CONFIG_EXISTS]}"
fi

echo -e "\n${C_DIM}-----------------------------------------------------${C_RESET}"
echo -e "${C_GREEN}${LANG[INSTALL_COMPLETE]}${C_RESET}"
echo -e "${LANG[CMD_INSTALLED]} '${C_BOLD}${command_name}${C_RESET}'"
echo -e "${C_YELLOW}${LANG[RESTART_NEEDED]}${C_RESET}"
echo
echo -e "${LANG[EXAMPLE]} ${C_BOLD}${command_name} 8.8.8.8${C_RESET}"
echo -e "${C_DIM}${LANG[UNINSTALL]} $APP_DIR $CONFIG_DIR $LAUNCHER_PATH${C_RESET}"
echo -e "${C_DIM}-----------------------------------------------------${C_RESET}"
