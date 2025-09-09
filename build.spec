# -*- mode: python ; coding: utf-8 -*-
import os
import sys
import torch

# Добавляем пути к библиотекам Conda
conda_env_path = os.environ.get('CONDA_PREFIX')
if conda_env_path:
    sys.path.append(os.path.join(conda_env_path, 'lib', 'python3.10', 'site-packages'))

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[os.getcwd()],
    binaries=[],
    datas=[],
    hiddenimports=[
        'torch',
        'torch._C',
        'torch.nn',
        'torch.nn.functional',
        'torch.backends.cudnn',
        # Добавьте другие скрытые импорты, если необходимо
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# Добавляем библиотеки PyTorch
pytorch_path = os.path.dirname(torch.__file__)
a.datas += [(pytorch_path, 'torch')]

# Добавляем shared libraries PyTorch
for root, dirs, files in os.walk(pytorch_path):
    for file in files:
        if file.endswith('.so'):
            a.binaries.append((os.path.join(root, file), root))

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='stl_processor',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

