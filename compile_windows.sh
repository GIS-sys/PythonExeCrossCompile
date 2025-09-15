#!/bin/bash

echo "Starting Windows build process..."
export WINEPREFIX=/root/.wine
export WINEARCH=win64

echo "Checking environment..."
wine python --version
wine pip list | grep -E "(pyinstaller|torch)"

echo "Building executable..."
cd /app

# Простая сборка без сложных флагов
wine pyinstaller --onefile --name stl_processor main.py

# Проверка результата
if [ -f "/app/dist/stl_processor.exe" ]; then
    echo "✅ Build successful! File: /app/dist/stl_processor.exe"
    ls -la /app/dist/
else
    echo "❌ Build failed"
    exit 1
fi

