FROM ubuntu:22.04

# Установка переменных окружения для избежания интерактивных вопросов
ENV DEBIAN_FRONTEND=noninteractive
ENV WINEDEBUG=-all
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64

# Установка системных зависимостей с multiarch
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    wget \
    wine64 \
    wine32 \
    winetricks \
    mingw-w64 \
    cabextract \
    p7zip-full \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Инициализация wine без GUI
RUN wine wineboot --init && \
    winetricks -q win10 && \
    winetricks -q vcrun2019 && \
    winetricks -q corefonts && \
    wineserver -w

# Установка Python 3.10 для Windows (без GUI)
RUN wget -q https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe -O /tmp/python.exe && \
    wine start /wait /b /min /unix /tmp/python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Shortcuts=0 && \
    rm /tmp/python.exe && \
    wineserver -w

# Установка pip для Windows
RUN wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && \
    wine python /tmp/get-pip.py && \
    rm /tmp/get-pip.py && \
    wineserver -w

# Установка необходимых библиотек
RUN wine pip install pyinstaller==5.13.0 torch==2.0.1 torchvision==0.15.2 --no-cache-dir && \
    wineserver -w

# Создание рабочей директории
WORKDIR /app

# Копирование исходного кода
COPY . .

# Установка прав на скрипты
RUN chmod +x build_windows.sh

CMD ["/bin/bash"]

