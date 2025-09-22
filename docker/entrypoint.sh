#!/usr/bin/sh

echo $MODE

mkdir -p /app/state
read -r PYTHON_VERSION < /app/project/__version__.txt
echo "PYTHON VERSION: $PYTHON_VERSION"



# Check installation state
if [ ! -f "/app/state/installation_complete_python$PYTHON_VERSION" ]; then
    echo "Running Python installation steps..."

    winetricks -q win10
    winetricks --force vcrun2019
    winetricks -q win10

    wine python --version
    wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe"
    wine ./python-${PYTHON_VERSION}-amd64.exe
    wine python --version
    wine pip install pyinstaller

    # Mark installation as complete in persistent storage
    touch /app/state/installation_complete_python
    echo "Python Installation completed successfully."
else
    echo "Python Installation already completed, skipping..."
    wine python --version
fi



echo "Starting main script with arguments: $@"
wine python --version

wine pip install -r /app/project/requirements.txt

cd /app/build
wine pyinstaller --onefile "Z:\\app\\project\\main.py"

