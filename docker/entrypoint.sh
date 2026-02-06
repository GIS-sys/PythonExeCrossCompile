#!/bin/bash

PYTHON_VERSION=$(tr -d '\r\n' < /app/project/__version__.txt)
echo "PYTHON VERSION: $PYTHON_VERSION"
echo "Mode: $MODE"
echo "Arguments for main.exe: $MAINARGS"
echo "Arguments for pyinstaller: $PYINSTALLERARGS"



# Check installation state
wine mamba
if wine mamba --version >/dev/null 2>&1; then
    echo -e "\n>>> Mamba installation already completed, skipping\n"
else
    echo -e "\n>>> Mamba is not installed, installing Mambaforge\n"

    # Uinstall python
    while true; do
        python_installed=$(wine python --version)
        if [[ "$python_installed" == "Application could not be started"* ]]; then
            break
        fi
        echo -e "\n>>> ... Uninstalling Python...\nChoose and uninstall previous version of python / conda\n"
        wine uninstaller
    done

    # Install required dependencies
    echo -e "\n>>> ... Installing VC2019\n"
    winetricks --force vcrun2019
    winetricks -q win10

    # Install conda
    echo -e "\n>>> ... Downloading Mambaforge\n"
    wget "https://github.com/conda-forge/miniforge/releases/download/24.7.1-0/Mambaforge-Windows-x86_64.exe" -O mambaforge.exe

    # Install Mambaforge silently
    echo -e "\n>>> ... Installing Mambaforge\n"
    wine mambaforge.exe /S /InstallationType=JustMe /AddToPath=1 /RegisterPython=0 /NoRegistry=1

    # Initialize mamba
    echo -e "\n>>> ... Initializing mamba\n"
    wine mamba init --no-user

    echo -e "\n>>> Mambaforge installation is completed\n"
fi



echo -e "\n>>> Configuring channels\n"
wine mamba config --set channel_priority strict
wine mamba config --add channels conda-forge
wine mamba config --set default_channels https://repo.anaconda.com/pkgs/main,https://repo.anaconda.com/pkgs/r,https://repo.anaconda.com/pkgs/msys2



# Create environment with specified python version
target_env_name="conda_env_py${PYTHON_VERSION}"

echo -e "\n>>> Removing old envs\n"
wine mamba env list | grep -vE "base|${target_env_name}|^#|^$" | awk '{print $1}' | while read env; do
    [[ "$env" =~ [A-Za-z] ]] && \
    echo -e "\n>>> ... Removing ^$env^" && \
    wine mamba env remove -n "${env}" -y
done

if wine mamba env list | grep -q "${target_env_name}"; then
    echo -e "\n>>> Environment ${target_env_name} already exists, skipping\n"
else
    echo -e "\n>>> Environment ${target_env_name} does not exist\n"
    wine mamba create -n ${target_env_name} python=${PYTHON_VERSION} -y
fi

wine_mamba_run() {
    wine mamba run -n ${target_env_name} --no-capture-output cmd /c "$*"
}
wine_mamba_run python --version



echo -e "\n>>> Installing mamba dependencies\n"
echo -e "\n>>> ... Cleaning mamba\n"
wine mamba clean -a -y
echo -e "\n>>> ... Installing base libs\n"
if wine_mamba_run pip install -r /app/docker/requirements.txt; then
    echo -e "\n>>> ... ... Base libs installed successfully\n"
else
    echo -e "\n>>> Error during installing base libs\n"
    exit 1
fi
echo -e "\n>>> ... Updating env with mamba\n"
if wine mamba env update -n ${target_env_name} -f /app/project/compile.environment.yaml -vv  2>&1; then
    echo -e "\n>>> ... ... Mamba environment updated successfully\n"
else
    echo -e "\n>>> Error during updating mamba env\n"
    exit 1
fi
echo -e "\n>>> ... Updating env with pip\n"
if wine_mamba_run pip install -r /app/project/requirements.txt; then
    echo -e "\n>>> ... ... Pip environment updated successfully\n"
else
    echo -e "\n>>> Error during updating pip env\n"
    exit 1
fi
echo -e "\n>>> ... Installed environment\n"



echo -e "\n>>> Starting main script\n"
wine_mamba_run python --version
wine --version
winetricks -q win10
wine_mamba_run pip freeze



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
        cd /app/build
        wine_mamba_run pyinstaller --noconfirm $PYINSTALLERARGS "Z:\\app\\project\\main.py"
        ;;
    "run-onefile")
        echo "Running previously compiled main.exe..."
        cd /app/runtime
        wine_mamba_run /app/build/dist/main.exe $MAINARGS
        ;;
    "run-onedir")
        echo "Running previously compiled main.exe..."
        cd /app/runtime
        wine_mamba_run /app/build/dist/main/main.exe $MAINARGS
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

