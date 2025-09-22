FROM ubuntu:24.04

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

# Install required packages with official Wine PPA
RUN apt-get update && apt-get install -y \
    wget \
    software-properties-common \
    gnupg2 \
    curl;
#RUN curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /usr/share/keyrings/winehq-archive-keyring.gpg \
#    && echo "deb [signed-by=/usr/share/keyrings/winehq-archive-keyring.gpg] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/winehq.list \
#    && dpkg --add-architecture i386 \
#    && apt-get update \
#    && apt-get install -y --install-recommends winehq-stable \
#    && apt-get install -y winetricks xvfb \
#    && rm -rf /var/lib/apt/lists/*;
RUN dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources;
RUN apt update;
RUN apt install -y --install-recommends winehq-stable && \
    apt install -y winetricks;

RUN winetricks -q win10;
ENTRYPOINT ["./project/entrypoint.sh"]
#CMD ["winetricks --force vcrun2019"]

#RUN winetricks --force vcrun2019;
#RUN winetricks -q win10;

#CMD ["wine"]

## Set up wine environment
#RUN winetricks -q win10;
#RUN winetricks vcrun2019;
#
## Download and install Python
#RUN wget https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe -O /tmp/python-installer.exe && \
#    xvfb-run wine /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 && \
#    rm /tmp/python-installer.exe;
#
## Install pip packages
#RUN wine pip install --upgrade pip && \
#    wine pip install pyinstaller && \
#    wine pip install numpy==2.3.3 && \
#    wine pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu
#
## Create working directory
#WORKDIR /app
#
## Copy project files
#COPY project/ /app/project/
#
## Create entrypoint script
#RUN echo '#!/bin/bash\n\
#export CROSS_PROJECT=$(echo "Z:"$(pwd)"/project/main.py" | tr / "\\\\")\n\
#mkdir -p build\n\
#cd build\n\
#if [ "$1" = "--onefile" ]; then\n\
#    wine pyinstaller --onefile "$CROSS_PROJECT"\n\
#elif [ "$1" = "--onefolder" ]; then\n\
#    wine pyinstaller --onefolder "$CROSS_PROJECT"\n\
#else\n\
#    echo "Usage: docker run <container> [--onefile|--onefolder]"\n\
#    echo "  --onefile:   Create single executable"\n\
#    echo "  --onefolder: Create folder distribution"\n\
#fi\n\
#' > /entrypoint.sh && chmod +x /entrypoint.sh
#
#ENTRYPOINT ["/entrypoint.sh"]

