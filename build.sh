#!/bin/bash

# Создаем виртуальное окружение
python3.10 -m venv venv
source venv/bin/activate

# Устанавливаем зависимости
pip install torch pyinstaller

# Собираем исполняемый файл
pyinstaller --onefile \
            --name stl_processor \
            --add-data "$(python -c 'import torch; print(torch.__path__[0])'):torch" \
            --hidden-import torch \
            --hidden-import torch._C \
            --runtime-hook runtime_hook.py \
            main.py

echo "Build completed! Executable: dist/stl_processor"

