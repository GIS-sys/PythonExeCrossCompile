import os
import sys

def fix_mkl_paths():
    """Исправляет пути для MKL библиотек"""
    if hasattr(sys, '_MEIPASS'):
        # Добавляем путь к библиотекам
        lib_path = os.path.join(sys._MEIPASS)
        os.environ['LD_LIBRARY_PATH'] = lib_path + os.pathsep + os.environ.get('LD_LIBRARY_PATH', '')
        
        # Устанавливаем переменные окружения для MKL
        os.environ['MKL_THREADING_LAYER'] = 'GNU'
        
        # Добавляем текущую директорию в путь поиска библиотек
        if hasattr(os, 'add_dll_directory'):
            os.add_dll_directory(sys._MEIPASS)

# Вызываем при импорте
fix_mkl_paths()

