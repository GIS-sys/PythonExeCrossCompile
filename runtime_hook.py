import os
import sys

# Добавляем пути к библиотекам PyTorch
if hasattr(sys, '_MEIPASS'):
    torch_path = os.path.join(sys._MEIPASS, 'torch')
    if os.path.exists(torch_path):
        sys.path.insert(0, torch_path)

