FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    WINEARCH=win64 \
    WINEPREFIX=/root/.wine \
    CROSS_PROJECT= \
    OMP_NUM_THREADS=1 \
    OMP_WAIT_POLICY=PASSIVE \
    KMP_BLOCKTIME=0 \
    KMP_AFFINITY=disabled \
    MKL_ENABLE_INSTRUCTIONS=AVX2 \
    MKL_DYNAMIC=FALSE

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    software-properties-common \
    gnupg2 \
    && wget -qO- https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main' \
    && apt-get update && apt-get install -y \
    winehq-stable \
    winetricks \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Set up wine environment
RUN winetricks -q win10 && \
    winetricks vcrun2022

# Download and install Python
RUN wget https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe -O /tmp/python-installer.exe && \
    xvfb-run wine /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 && \
    rm /tmp/python-installer.exe

# Install pip packages
RUN wine pip install --upgrade pip && \
    wine pip install pyinstaller && \
    wine pip install numpy==2.3.3 && \
    wine pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu

# Create working directory
WORKDIR /app

# Copy project files
COPY project/ /app/project/

# Create entrypoint script
RUN echo '#!/bin/bash\n\
export CROSS_PROJECT=$(echo "Z:"$(pwd)"/project/main.py" | tr / "\\\\")\n\
mkdir -p build\n\
cd build\n\
if [ "$1" = "--onefile" ]; then\n\
    wine pyinstaller --onefile "$CROSS_PROJECT"\n\
elif [ "$1" = "--onefolder" ]; then\n\
    wine pyinstaller --onefolder "$CROSS_PROJECT"\n\
else\n\
    echo "Usage: docker run <container> [--onefile|--onefolder]"\n\
    echo "  --onefile:   Create single executable"\n\
    echo "  --onefolder: Create folder distribution"\n\
fi\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

