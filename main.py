import sys
import os
import torch
from pathlib import Path

def main():
    # Проверяем количество аргументов
    if len(sys.argv) != 3:
        print("Usage: program path_to_stl=... target_folder=...")
        return 1
    
    # Парсим аргументы
    try:
        args = {}
        for arg in sys.argv[1:]:
            if '=' in arg:
                key, value = arg.split('=', 1)
                args[key] = value
            else:
                print(f"Invalid argument format: {arg}")
                return 1
        
        path_to_stl = args.get('path_to_stl')
        target_folder = args.get('target_folder')
        
        if not path_to_stl or not target_folder:
            print("Missing required arguments: path_to_stl and target_folder")
            return 1
            
    except Exception as e:
        print(f"Error parsing arguments: {e}")
        return 1
    
    try:
        # Проверяем существование исходного файла
        if not os.path.exists(path_to_stl):
            print(f"Source file does not exist: {path_to_stl}")
            return 1
        
        # Создаем целевую директорию если её нет
        os.makedirs(target_folder, exist_ok=True)
        
        # Выполняем вычисления с PyTorch (перемножение матриц)
        print("Performing matrix multiplication with PyTorch...")
        
        # Создаем две матрицы
        matrix_a = torch.randn(100, 100)
        matrix_b = torch.randn(100, 100)
        
        # Перемножаем матрицы
        result = torch.matmul(matrix_a, matrix_b)
        
        print(f"Matrix multiplication completed. Result shape: {result.shape}")
        
        # Создаем имя для .obj файла
        stl_path = Path(path_to_stl)
        obj_filename = stl_path.stem + ".obj"
        obj_path = os.path.join(target_folder, obj_filename)
        
        # Создаем .obj файл (в данном случае просто заглушку)
        with open(obj_path, 'w') as obj_file:
            obj_file.write("# Generated OBJ file\n")
            obj_file.write(f"# Original STL: {path_to_stl}\n")
            obj_file.write("o GeneratedObject\n")
            # Здесь можно добавить реальное содержимое OBJ файла
        
        print(f"Created OBJ file: {obj_path}")
        
        # Создаем .txt файл с информацией
        txt_filename = stl_path.stem + ".txt"
        txt_path = os.path.join(target_folder, txt_filename)
        
        with open(txt_path, 'w') as txt_file:
            txt_file.write(f"Source STL file: {path_to_stl}\n")
            txt_file.write(f"Generated OBJ file: {obj_path}\n")
            txt_file.write(f"Target folder: {target_folder}\n")
            txt_file.write("Processing completed successfully.\n")
        
        print(f"Created info file: {txt_path}")
        print("Processing completed successfully!")
        
        return 0
        
    except Exception as e:
        print(f"Error during processing: {e}")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

