# About

This repository provides an example and a step-by-step guide for cross-compilation of Python project into a standalone ".exe" file for Windows

Below you will find sections for how to compile and run your code on Ubuntu, as well as useful warnings and tips about potential problems that can occur



# Compilation and testing

You can compile the code either via docker (preferable), or via manual installation of wine on your PC

## Docker (preferable)

0) Install docker and docker compose (f. e. [this official tutorial](https://docs.docker.com/compose/install/))

1) Prepare your project for compilation. There are three paths here, depending on what you need:

    1) only run the example without thinking:

       Just skip this step in this case

    2) play with the example / copy your source code into current folder:

        1) modify `project/__version__.txt` file according to your preferred python version in full form (3.12.10, not 3.12)

        2) modify `project/requirements.txt` file with required libraries and their versions

        3) put all the source files into a `project/` folder with `project/main.py` as an entry point

    3) compile your code located in another directory:

        1) create `/path/to/your/project/__version__.txt` file with preferred python version in full form (3.12.10, not 3.12)

        2) create `/path/to/your/project/requirements.txt` file with required libraries and their versions

        3) make sure `/path/to/your/project/main.py` is the entry point for your entire application

        4) modify the `docker/docker-compose.yml` file, changing the line `- ../project:/app/project:ro` (in `services.windows-builder.volumes`) to `- /path/to/your/project:/app/project:ro`

2) If this is your first time using this repository, use `./run.sh` to build the initial docker image and install basic components. Running this script for the first time may take 5-10 minutes even on high-end hardware and high-speed internet connections. After few minutes have passed, the docker image itself should launch, and you will be prompted to install some of the following:

    1) Wine Mono Installer

       It is a small window with two buttons: Cancel and Install. Press Install and wait for the download to end

    2) Visual Studio

       I didn't get the prompt last time I checked, in case you are prompted to do something - please open an issue / PR and describe the steps you were prompted to take

    3) Python

       Check both checkboxes ("Use admin priviliges ..." and "Add python.exe to PATH"), then click "Install Now", after installation is finished click "Close"

3) Compile the application. There are several options, depending on what you need:

    1) only run the example without thinking:

       Run `./run.sh`

    2) compile the project into a single .exe file, with all of the dependencies packaged inside:

       Run `./run.sh MODE=compile-onefile`

    3) compile the project into a single directory, containing both `.exe` file as well as some dependencies (faster to execute, but more clumsier):

       Run `./run.sh MODE=compile-onedir`

    4) if you want to compile and pass some custom arguments directly to the pyinstaller:

       Run something like `./run.sh MODE=compile PYINSTALLERARGS="--onefile --nowindowed"` (you can of course modify the PYINSTALLERARGS argument)

4) Run the application:

    1) If you compiled the example directly, use `./run.sh MODE=run-onefile MAINARGS="path_to_stl=a.stl target_folder=b"`

    2) If you compiled via "onefile" mode: `./run.sh MODE=run-onefile`

    3) If you compile via "onedir" mode: `./run.sh MODE=run-onedir`

    4) You can also add arguments to the running script. For example, if you compiled via "onefile" and want to run ".\\main.exe A=123 B=qwe", then use: `./run.sh MODE=run-onefile MAINARGS="A=123 B=qwe"`



## Manual (Ubuntu)

0) Add wine repository:

```bash
dpkg --add-architecture i386 && \
mkdir -pm755 /etc/apt/keyrings && \
wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources;
```

Install wine:

```bash
sudo apt install --install-recommends winehq-stable
sudo apt install winetricks
winetricks vcrun2022
winetricks -q win10
```

1) Download the python installer https://www.python.org/downloads/release/python-31210/

```bash
wget https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe
```

2) Install python on wine

```bash
wine ./python-3.12.10-amd64.exe
# (check both "use admin priviliges" and "add to Path") when prompted
```

and pyinstaller

```bash
wine pip install pyinstaller
```

3) Put all source files into `project/` folder with `main.py` as an entry point

4) Set an env variable for convenience (it's a path to main.py, but how it's visible from wine):

```bash
CROSS_PROJECT=$(echo "Z:"$(pwd)"/project/main.py" | tr / \\)
```

5) Run compilation:

install required libraries

```bash
wine pip install numpy==2.3.3
wine pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu
```

enter build directory

```bash
mkdir build && cd build
```

- Either to one exe file:
```bash
wine pyinstaller --onefile "$CROSS_PROJECT"
```

- Or to a single folder:
```bash
wine pyinstaller --onefolder "$CROSS_PROJECT"
```

6) Test:

```bash
cd dist/
wine main.exe path_to_stl=test.stl target_folder=./output
```



# Important notes

- If you are using numpy, you should put version <=2.2.1 because 2.2.2+ is broken for current wine (v10.0)

- pyinstaller doesn't seem to support multithreading. If you or library you imported uses it, you should disable it by putting the following lines in the *very* beginning of main.py, even before any other import:

```python
from multiprocessing import Process, freeze_support

if __name__ == '__main__':
    freeze_support()
    # import something
    # ... do other stuff ...
```

However, this may not be sufficient especially when trying to launch exe with WINE. So before calling "wine main.exe", export this env variables:
```bash
export OMP_NUM_THREADS=1
export OMP_WAIT_POLICY=PASSIVE
export KMP_BLOCKTIME=0
export KMP_AFFINITY=disabled

export MKL_ENABLE_INSTRUCTIONS=AVX2
export MKL_DYNAMIC=FALSE
```

Also, if needed, look at [this SO question](https://stackoverflow.com/questions/24944558/pyinstaller-built-windows-exe-fails-with-multiprocessing)

- in general, consult [official pyinstaller FAQ section](https://pyinstaller.org/en/latest/common-issues-and-pitfalls.html) in case of some problems



# TODO

- use proper windows docker base image: https://hub.docker.com/r/microsoft/windows-servercore/

- use nuitka instead of pyinstaller: https://habr.com/ru/articles/838480/

