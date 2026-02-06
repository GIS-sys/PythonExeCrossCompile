#!/bin/bash

PYTHON_VERSION=$(tr -d '\r\n' < /app/project/__version__.txt)
echo "PYTHON VERSION: $PYTHON_VERSION"
echo "Mode: $MODE"
echo "Arguments for main.exe: $MAINARGS"
echo "Arguments for pyinstaller: $PYINSTALLERARGS"



# Check installation state
wine conda
conda_installed=$(wine conda)
if [[ "$conda_installed" == *"conda is a tool"* ]]; then
    echo -e "\n>>> Conda installation already completed, skipping\n"
else
    echo -e "\n>>> Conda is not installed\n"

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
    echo -e "\n>>> ... Downloading conda\n"
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -O miniconda.exe
    echo -e "\n>>> ... Installing conda\n"
    wine miniconda.exe /S /InstallationType=JustMe /AddToPath=1 /RegisterPython=0

    echo -e "\n>>> Conda installation is completed\n"
fi



echo -e "\n>>> Accepting conda tos\n"
wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
wine conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2



# Create environment with specified python version
target_env_name="conda_env_py${PYTHON_VERSION}"

echo -e "\n>>> Removing old envs\n"
wine conda env list | grep -vE "base|${target_env_name}|^#|^$" | awk '{print $1}' | while read env; do
    [[ "$env" =~ [A-Za-z] ]] && \
    echo -e "\n>>> ... Removing ^$env^" && \
    wine conda env remove -n "${env}" -y
done

if wine conda env list | grep -q "${target_env_name}"; then
    echo -e "\n>>> Environment ${target_env_name} already exists, skipping\n"
else
    echo -e "\n>>> Environment ${target_env_name} does not exist\n"
    wine conda init
    wine conda config --add channels conda-forge
    wine conda create -n ${target_env_name} python=${PYTHON_VERSION} -y > /tmp/a && cat /tmp/a
fi

wine_conda_run() {
    wine cmd /c "conda activate ${target_env_name} & $*"
}
wine_conda_run python --version



echo -e "\n>>> Installing conda dependencies\n"
wine conda config --add channels conda-forge
wine conda config --set channel_priority strict
echo -e "\n>>> ... Updating base mamba\n"
conda update -n base --all
echo -e "\n>>> ... Installing mamba\n"
wine conda install -n base mamba -y
echo -e "\n>>> ... Cleaning mamba\n"
wine mamba clean -a
echo -e "\n>>> ... Initiating mamba\n"
wine mamba init
echo -e "\n>>> ... Updating env with mamba\n"
wine mamba env update -n ${target_env_name} -f /app/project/compile.environment.yaml -y
#wine conda install -n base conda-libmamba-solver --yes
#echo -e "\n>>> ... Installed libmamba solver\n"
#wine conda config --set solver libmamba
#echo -e "\n>>> ... Set libmamba solver as default\n"
#wine conda env update -n ${target_env_name} -f /app/project/compile.environment.yaml -vv 2>&1
#wine conda env update -n ${target_env_name} -f /app/project/compile.environment.yaml -vv --json 2>&1
#wine conda env update -n ${target_env_name} -f /app/project/compile.environment.yaml 2>&1 | tee /tmp/conda_update.log
echo -e "\n>>> ... Installed environment\n"
exit
if wine conda env update -n ${target_env_name} -f /app/project/compile.environment.yaml --dry-run 2>&1 | grep -q "All requested packages already installed"; then
    echo "\n>>> ... Environment matches environment.yml\n"
else
    echo "\n>>> Environment DOES NOT match environment.yml\n"
    exit 1
fi



echo -e "\n>>> Starting main script\n"
wine_conda_run python --version
wine --version
winetricks -q win10
wine_conda_run pip freeze



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
        wine_conda_run pyinstaller --noconfirm $PYINSTALLERARGS "Z:\\app\\project\\main.py"
        ;;
    "run-onefile")
        echo "Running previously compiled main.exe..."
        cd /app/runtime
        wine_conda_run /app/build/dist/main.exe $MAINARGS
        ;;
    "run-onedir")
        echo "Running previously compiled main.exe..."
        cd /app/runtime
        wine_conda_run /app/build/dist/main/main.exe $MAINARGS
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

