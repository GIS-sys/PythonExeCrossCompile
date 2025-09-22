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
    curl &&\
    dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources;
RUN apt update && \
    apt install -y --install-recommends winehq-stable && \
    apt install -y winetricks;

CMD ["/bin/bash"]

