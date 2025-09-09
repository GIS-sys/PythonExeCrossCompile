#!/bin/bash

echo "Starting Windows build process..."

# Активируем wine environment
export WINEPREFIX=/root/.wine
export WINEARCH=win64

echo "Checking wine setup..."
wine python --version
wine pip --version

echo "Building executable..."
cd /app

# Используем более простой подход без сложных флагов
wine pyinstaller --onefile \
                 --name stl_processor \
                 --console \
                 main.py

echo "Build completed! Checking result..."
if [ -f "/app/dist/stl_processor.exe" ]; then
    echo "✅ SUCCESS: stl_processor.exe created successfully!"
    echo "📁 Location: /app/dist/stl_processor.exe"
    ls -la /app/dist/
else
    echo "❌ FAILED: stl_processor.exe was not created"
    exit 1
fi

