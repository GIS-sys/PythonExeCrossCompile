#!/bin/bash

export DISPLAY=:99
export WINEDLLOVERRIDES="mscoree,mshtml,winemenubuilder="
export WINEDEBUG=-all

Xvfb $DISPLAY -screen 0 720x720x24 2>/dev/null &
XVFB_PID=$!
echo "Started Xvfb on $DISPLAY with PID $XVFB_PID"

sleep 3

mkdir -p /app/state
read -r PYTHON_VERSION < /app/project/__version__.txt
echo "PYTHON VERSION: $PYTHON_VERSION"
echo "Mode: $MODE"
echo "Arguments for main.exe: $MAINARGS"
echo "Arguments for pyinstaller: $PYINSTALLERARGS"
echo "Uvicorn command: $UVICORN_CMD"

# Check installation state
installed_version=$(wine python --version)
required_version=$(printf "Python ${PYTHON_VERSION}\15")
if [[ $installed_version != $required_version ]]; then
    cd /app/state
    while true; do
        python_installed=$(wine python --version)
        if [[ "$python_installed" == "Application could not be started"* ]]; then
            break
        fi
        echo -e "\n\nUninstalling Python...\nChoose and uninstall previous version of python"
        wine uninstaller

        sleep 5
    done

    echo "Downloading and silently installing VC_redist"
    VCRUNTIME_URL="https://aka.ms/vs/16/release/vc_redist.x86.exe"
    VCRUNTIME_CACHE_PATH="/root/.cache/winetricks/vcrun2019"
    VCRUNTIME_EXE="$VCRUNTIME_CACHE_PATH/vc_redist.x86.exe"

    mkdir -p "$VSCRUNTIME_CACHE_PATH"
    wget -O "$VCRUNTIME_EXE" "$VCRUNTIME_URL"

    wine "$VCRUNTIME_EXE" /install /passive /norestart

    if [[ $? -ne 0 ]]; then
        echo "Error: VC_redist silent install failed"
    fi

    winetricks -q win10

    wine python --version
    wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe"
    PYTHON_EXE="python-${PYTHON_VERSION}-amd64.exe"
    wine python --version
    echo "Installing Python silently..."
    wine ./"$PYTHON_EXE" /quiet InstallAllUsers=1 PrependPath=1
    if [ $? -ne 0 ]; then
        echo "Warning: Python silent install returned a non-zero code"
    fi
    wine pip install -r /app/docker/requirements.txt
    if [ $? -ne 0 ]; then
        echo "Error: pip install failed1"
        exit 1
    fi

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

if [[ "$MODE" == "compile-onefile" ]]; then
   PYINSTALLERARGS="$PYINSTALLERARGS --onefile"
fi
if [[ "$MODE" == "compile-onedir" ]]; then
   PYINSTALLERARGS="$PYINSTALLERARGS --onedir"
fi

case "$MODE" in
    "compile"*)
        echo "Compilation..."
        wine pip install -r /app/project/requirements.txt
        if [ $? -ne 0 ]; then
            echo "Error: pip install failed"
            exit 1
        fi
        cd /app/build
        wine pyinstaller --noconfirm $PYINSTALLERARGS "Z:\\app\\project\\main.py"
        ;;
    "run-onefile"|"run-onedir")
        echo "Running previously compiled main.exe..."
        cd /app/project
    
        echo "Current directory: $(pwd)"
        echo "Starting main.exe which will launch FastAPI server..."
        
        if [[ "$MODE" == "run-onefile" ]]; then
            wine /app/build/dist/main.exe
        else
            wine /app/build/dist/main/main.exe
        fi
        ;;
    *)
        echo "Error: Unknown mode '$MODE'"
        echo "Available modes: compile-onefile, compile-onedir, compile, run-onefile, run-onedir"
        exit 1
        ;;
esac

if [[ $MODE == "compile"* ]] && [[ $PYINSTALLERARGS == *"--onedir"* ]]; then
    cd /app/build/dist/
    zip -r -q -T --symlinks main.zip main/
fi

kill $XVFB_PID
