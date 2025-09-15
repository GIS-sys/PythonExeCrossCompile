USE .ENV FILE AND DOCKER ARGS!!!!!!!!!

# Docker compilation

0) Install docker

1) Put preferred python version in `__version__.txt` in full form (3.12.10, not 3.12)

2) Put required libraries in `requirements.txt`

3) Put all source files into `project/` folder with `main.py` as an entry point

4) Run ./compile_windows.sh

# Manual compilation

0) Install wine

```bash
sudo apt install --install-recommends winehq-stable
wine winecfg -v win10
```

1) Download the python installer https://www.python.org/downloads/release/python-31210/

```bash
wget https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe
```

2) Install python on wine

```bash
wine ./python-3.12.1-amd64.exe
# (check both "use admin priviliges" and "add to Path")
```

3) Put all source files into `project/` folder with `main.py` as an entry point

4) Set an env variable:

```bash
CROSS_PROJECT=$(echo "Z:"$(pwd)"/main.py" | tr / \\)
```

5) Run compilation:

```bash
mkdir build && cd build
```

- Either to one exe file:
```bash
wine pyinstaller --onefile $CROSS_PROJECT
```

- Or to a single folder:
```bash
wine pyinstaller --onefolder $CROSS_PROJECT
```


docker build -t windows-builder .

# Запустите контейнер и выполните сборку
docker run -it --rm \
  -v $(pwd):/app \
  -v $(pwd)/output:/app/dist \
  windows-builder \
  ./build_windows.sh



# Тестируем .exe файл в wine
cd output
wine stl_processor.exe path_to_stl=test.stl target_folder=./output

# Проверяем код возврата
echo $?
