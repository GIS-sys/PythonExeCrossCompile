FROM ubuntu:22.04

# Установка переменных окружения для избежания интерактивных вопросов
ENV DEBIAN_FRONTEND=noninteractive

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    wget \
    wine64 \
    winetricks \
    mingw-w64 \
    cabextract \
    && rm -rf /var/lib/apt/lists/*

# Настройка wine
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64

# Установка Python 3.10 для Windows
RUN wget -q https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe -O /tmp/python.exe && \
    wine wineboot --init && \
    wine /tmp/python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 && \
    rm /tmp/python.exe

# Установка pip для Windows
RUN wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && \
    wine python /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# Установка необходимых библиотек
RUN wine pip install pyinstaller==5.13.0 torch==2.0.1 torchvision==0.15.2 --no-cache-dir

# Создание рабочей директории
WORKDIR /app

# Копирование исходного кода
COPY . .

# Установка прав на скрипты
RUN chmod +x build_windows.sh

CMD ["/bin/bash"]

