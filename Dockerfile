FROM ubuntu:22.04

# Установка переменных окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV WINEDEBUG=-all
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64

# Установка системных зависимостей
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

# Инициализация wine без проблемных winetricks
RUN wine wineboot --init && \
    wineserver -w

# Пропускаем проблемные winetricks и устанавливаем Python напрямую
RUN wget -q https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe -O /tmp/python.exe && \
    wine start /wait /min /unix /tmp/python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Shortcuts=0 && \
    rm /tmp/python.exe && \
    wineserver -w

# Установка pip
RUN wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && \
    wine python /tmp/get-pip.py && \
    rm /tmp/get-pip.py && \
    wineserver -w

# Установка pyinstaller и torch
RUN wine pip install pyinstaller==5.13.0 && \
    wineserver -w

# Для torch используем версию без CUDA чтобы уменьшить зависимости
RUN wine pip install torch==2.0.1 --index-url https://download.pytorch.org/whl/cpu && \
    wineserver -w

WORKDIR /app
COPY . .

CMD ["/bin/bash"]
