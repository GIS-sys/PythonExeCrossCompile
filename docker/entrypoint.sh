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
    echo -e "\n\nA\n\n"
    wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe"
    echo -e "\n\nB\n\n"
    wine ./python-${PYTHON_VERSION}-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
    echo -e "\n\nC\n\n"
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -O miniconda.exe
    echo -e "\n\nD\n\n"
    wine miniconda.exe tos accept --override-channels --channel https://repo.anaconda.com/pkg
    echo -e "\n\nE\n\n"
    wine miniconda.exe /S /InstallationType=JustMe /AddToPath=1 /RegisterPython=0
    echo -e "\n\nF\n\n"

    sleep 5

    export WINEPATH="C:\\Miniconda3;C:\\Miniconda3\\Scripts;C:\\Miniconda3\\Library\\bin;$WINEPATH"
    echo -e "\n\nG\n\n"
    wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkg
    echo -e "\n\nH\n\n"
    wine conda init
    echo -e "\n\nI\n\n"
    wine conda config --add channels conda-forge
    echo -e "\n\nJ\n\n"
    wine conda config --set channel_priority strict
    echo -e "\n\nK\n\n"

    wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
    wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
    wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2
    echo -e "\n\nKL\n\n"
    wine conda install -c conda-forge pythonocc-core=7.7.0 -y
    echo -e "\n\nL\n\n"

    wine python -m pip install --upgrade pip
    wine pip install -r /app/docker/requirements.txt

    wine python -c "import OCC; print(f'pythonocc-core успешно установлен: {OCC.__version__}')"
    if [ $? -ne 0 ]; then
        echo "Error: pip install failed"
        exit 1
    fi

    # Mark installation as complete in persistent storage
    touch /app/state/installation_complete_python$PYTHON_VERSION
    echo "Python Installation completed successfully."
else
    echo "Python Installation already completed, skipping..."
    wine conda config --set solver classic > /tmp/b && cat /tmp/b
    echo -e "\n\nZ\n\n"
    wine conda config --system --set solver classic && wine conda update --all -y
    echo -e "\n\nY\n\n"
    #wine conda config --set solver classic
    #wine python --version
    #wine conda create -n myenv python=${PYTHON_VERSION} -y
    wine conda activate myenv
    wine conda env list

    wine conda list
    #wine conda install -c conda-forge pythonocc-core=7.9.0 -y > /tmp/a && cat /tmp/a
    #wine conda list
    exit
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

