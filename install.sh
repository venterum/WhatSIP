#!/bin/bash

echo "Установка WhatSIP"
echo "================="
echo

# 1. Проверяем, что находимся в директории с проектом
if [ ! -f "main.py" ] || [ ! -f "requirements.txt" ]; then
    echo "Ошибка: Не найдены 'main.py' или 'requirements.txt'."
    echo "Убедитесь, что вы запускаете скрипт из корневой директории проекта."
    exit 1
fi

# 2. Проверка наличия python3 и модуля venv
echo "Проверка Python и модуля venv..."
if ! command -v python3 &> /dev/null; then
    echo "Ошибка: Python 3 не найден. Пожалуйста, установите Python 3."
    exit 1
fi
if ! python3 -c "import venv" &> /dev/null; then
    echo "Ошибка: Модуль 'venv' для Python 3 не найден."
    echo "Пожалуйста, установите его. Пример для Debian/Ubuntu: sudo apt install python3-venv"
    exit 1
fi

# 3. Предлагаем выбрать имя команды
echo "Какую команду для вызова вы хотите использовать?"
echo "1) whatsip (рекомендуется)"
echo "2) ws"
echo "3) Своё имя"
read -p "Выберите вариант [1-3]: " name_choice

case $name_choice in
    1)
        command_name="whatsip"
        ;;
    2)
        command_name="ws"
        ;;
    3)
        read -p "Введите желаемое имя команды: " command_name
        if [ -z "$command_name" ]; then
            echo "Имя не может быть пустым. Используем 'whatsip'."
            command_name="whatsip"
        fi
        ;;
    *)
        echo "Неверный выбор. Используем имя 'whatsip'."
        command_name="whatsip"
        ;;
esac

# 4. Создаем изолированное окружение
APP_DIR="$HOME/.local/share/whatsip"
echo "Создание изолированного окружения в $APP_DIR..."
rm -rf "$APP_DIR" # Удаляем старую установку, если она есть
mkdir -p "$APP_DIR"
python3 -m venv "$APP_DIR/venv"

# 5. Устанавливаем зависимости в это окружение
echo "Установка зависимостей (requests, rich) в окружение..."
"$APP_DIR/venv/bin/pip" install --upgrade pip > /dev/null
"$APP_DIR/venv/bin/pip" install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось установить зависимости."
    echo "Попробуйте удалить директорию '$APP_DIR' и запустить установку заново."
    exit 1
fi

# 6. Копируем основной скрипт
cp main.py "$APP_DIR/"

# 7. Создаем скрипт-лаунчер в ~/.local/bin
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
LAUNCHER_PATH="$INSTALL_DIR/$command_name"

echo "Создание лаунчера в $LAUNCHER_PATH..."
# Очищаем старый лаунчер, если он существует
rm -f "$LAUNCHER_PATH" 
# Создаем новый лаунчер
cat << EOF > "$LAUNCHER_PATH"
#!/bin/bash
# Лаунчер для WhatSIP
APP_HOME="\$HOME/.local/share/whatsip"
"\$APP_HOME/venv/bin/python" "\$APP_HOME/main.py" "\$@"
EOF

chmod +x "$LAUNCHER_PATH"

# 8. Добавляем директорию в PATH, если это необходимо
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Добавляем $INSTALL_DIR в PATH..."
    shell_config_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    path_export_line="export PATH=\"\$HOME/.local/bin:\$PATH\""

    for config_file in "${shell_config_files[@]}"; do
        if [ -f "$config_file" ] && ! grep -q "# WhatSIP path" "$config_file"; then
            echo -e "\n# WhatSIP path\n$path_export_line" >> "$config_file"
            echo "Добавлена строка в $config_file"
        fi
    done
fi

# 9. Управление файлом конфигурации (логика остается той же)
CONFIG_DIR="$HOME/.config/whatsip"
CONFIG_FILE="$CONFIG_DIR/config.json"

echo
echo "Настройка конфигурационного файла..."
mkdir -p "$CONFIG_DIR"

if [ -f "config.json" ] && [ ! -f "$CONFIG_FILE" ]; then
    cp config.json "$CONFIG_FILE"
    echo "Локальная конфигурация скопирована в $CONFIG_FILE."
fi
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Файл конфигурации будет автоматически создан при первом запуске команды '$command_name' в '$CONFIG_FILE'."
else
    echo "Обнаружен существующий глобальный конфиг в '$CONFIG_FILE'."
fi

echo
echo "Установка завершена!"
echo "Команда '$command_name' была установлена в $INSTALL_DIR/"
echo "Для завершения установки перезапустите терминал или выполните 'source ~/.bashrc' (или .zshrc/.profile)."
echo
echo "Пример использования: $command_name 8.8.8.8"
echo "Для удаления утилиты просто удалите директории '$APP_DIR', '$CONFIG_DIR' и файл '$LAUNCHER_PATH'."
