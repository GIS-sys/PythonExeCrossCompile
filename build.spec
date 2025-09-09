# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[
        'torch', 
        'torch._C',
        'torch.nn',
        'torch.nn.functional',
        'torch.backends.cudnn',
        'numpy.core._multiarray_umath',
        'numpy.core._multiarray_tests',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=['runtime_hook.py'],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# Добавляем MKL библиотеки
import torch
import os

# Находим MKL библиотеки
conda_env_path = os.environ.get('CONDA_PREFIX', '')
if conda_env_path:
    lib_path = os.path.join(conda_env_path, 'lib')
    if os.path.exists(lib_path):
        for lib_file in os.listdir(lib_path):
            if lib_file.startswith('libmkl_') and lib_file.endswith('.so'):
                src_path = os.path.join(lib_path, lib_file)
                a.binaries.append((lib_file, src_path, "EXTENSION"))

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

