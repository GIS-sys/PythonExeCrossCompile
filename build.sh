#!/bin/bash

eval "$(conda shell.bash hook)"

# Активируем conda environment
conda activate stl_processor

# Проверяем, что environment активирован
if [ -z "$CONDA_PREFIX" ]; then
    echo "Conda environment not activated. Exiting."
    exit 1
fi

echo "Building with Conda environment: $CONDA_PREFIX"

# Собираем с помощью PyInstaller
pyinstaller build.spec

echo "Build completed! Executable: dist/stl_processor"

