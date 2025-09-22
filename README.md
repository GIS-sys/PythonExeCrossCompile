# Docker compilation

0) Install docker

1) Prepare project/ folder:

    - create `project/__version__.txt` file with preferred python version in full form (3.12.10, not 3.12)

    - create `project/requirements.txt` file with required libraries

    - put all the source files into `project/` folder with `main.py` as an entry point

2) Run ./compile_windows.sh



# Manual compilation

0) Install wine

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
# (check both "use admin priviliges" and "add to Path")
```

and pyinstaller

```bash
wine pip install pyinstaller
```

3) Put all source files into `project/` folder with `main.py` as an entry point

4) Set an env variable:

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



# Тестируем .exe файл в wine

```bash
cd dist/
wine main.exe path_to_stl=test.stl target_folder=./output
```



install wine, winetricks

winetricks install vs 2019
winetricks -q win10

install python
install numpy
install torch


export OMP_NUM_THREADS=1
export OMP_WAIT_POLICY=PASSIVE
export KMP_BLOCKTIME=0
export KMP_AFFINITY=disabled

export MKL_ENABLE_INSTRUCTIONS=AVX2
export MKL_DYNAMIC=FALSE

install pyinstaller

