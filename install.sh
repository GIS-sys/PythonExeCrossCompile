eval "$(conda shell.bash hook)"

conda create -n stl_processor python=3.10 -y  # Создаем environment с Python 3.10

conda activate stl_processor  # Активируем environment

#conda env list

conda install pytorch torchvision torchaudio cpuonly -c pytorch -y  # Устанавливаем PyTorch (выберите подходящую версию с официального сайта pytorch.org)

conda install -c conda-forge pyinstaller -y  # Устанавливаем PyInstaller

