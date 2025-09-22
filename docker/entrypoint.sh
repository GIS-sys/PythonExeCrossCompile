#!/usr/bin/sh

mkdir -p /app/state
read -r PYTHON_VERSION < /app/project/__version__.txt
echo "PYTHON VERSION: $PYTHON_VERSION"
echo "Mode: $MODE"



# Check installation state
if [ ! -f "/app/state/installation_complete_python$PYTHON_VERSION" ]; then
    echo "Running Python installation steps..."

    winetricks --force vcrun2019
    winetricks -q win10

    wine python --version
    wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe"
    wine ./python-${PYTHON_VERSION}-amd64.exe
    wine python --version
    wine pip install pyinstaller

    # Mark installation as complete in persistent storage
    touch /app/state/installation_complete_python$PYTHON_VERSION
    echo "Python Installation completed successfully."
else
    echo "Python Installation already completed, skipping..."
    wine python --version
fi



echo "Starting main script"
wine python --version
wine --version
winetricks -q win10
wine pip freeze



export OMP_NUM_THREADS=1
export OMP_WAIT_POLICY=PASSIVE
export KMP_BLOCKTIME=0
export KMP_AFFINITY=disabled
export MKL_ENABLE_INSTRUCTIONS=AVX2
export MKL_DYNAMIC=FALSE

case "$MODE" in
    compile)
        echo "Compilation..."
        wine pip install -r /app/project/requirements.txt
        cd /app/build
        wine pyinstaller --onefile "Z:\\app\\project\\main.py"
        ;;
    run)
        echo "Running previously compiled main.exe..."
        cd /app/build/dist
        wine python ./main.exe
        ;;
    *)
        echo "Error: Unknown mode '$MODE'"
        echo "Available modes: compile, run"
        exit 1
        ;;
esac

