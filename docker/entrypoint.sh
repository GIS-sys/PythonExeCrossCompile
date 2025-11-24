#!/bin/bash

mkdir -p /app/state
PYTHON_VERSION=$(tr -d '\r\n' < /app/project/__version__.txt)
echo "PYTHON VERSION: $PYTHON_VERSION"
echo "Mode: $MODE"
echo "Arguments for main.exe: $MAINARGS"
echo "Arguments for pyinstaller: $PYINSTALLERARGS"



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
    done

    winetricks --force vcrun2019
    winetricks -q win10

    wine python --version
    wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe"
    wine ./python-${PYTHON_VERSION}-amd64.exe
    wine python --version
    wine pip install -r /app/docker/requirements.txt
    if [ $? -ne 0 ]; then
        echo "Error: pip install failed"
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
    "run-onefile")
        echo "Running previously compiled main.exe..."
        cd /app/runtime
        wine /app/build/dist/main.exe $MAINARGS
        ;;
    "run-onedir")
        echo "Running previously compiled main.exe..."
        cd /app/runtime
        wine /app/build/dist/main/main.exe $MAINARGS
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

