import sys
import os
import torch
from pathlib import Path

def main():
    print("Windows PyTorch Test Application")
    print("=" * 40)

    # Простая проверка аргументов
    if len(sys.argv) < 3:
        print("Usage: stl_processor.exe path_to_stl=... target_folder=...")
        return 1

    # Проверяем что PyTorch работает
    try:
        print("Testing PyTorch...")
        a = torch.tensor([[1, 2], [3, 4]])
        b = torch.tensor([[5, 6], [7, 8]])
        result = torch.matmul(a, b)
        print(f"PyTorch test passed! Result:\n{result}")
    except Exception as e:
        print(f"PyTorch test failed: {e}")
        return 1

    # Простая имитация работы с файлами
    try:
        path_to_stl = sys.argv[1].split('=')[1]
        target_folder = sys.argv[2].split('=')[1]

        print(f"Input STL: {path_to_stl}")
        print(f"Output folder: {target_folder}")

        # Создаем простые файлы
        stl_path = Path(path_to_stl)
        obj_file = stl_path.stem + ".obj"
        txt_file = stl_path.stem + ".txt"

        # Записываем тестовые файлы
        with open(obj_file, 'w') as f:
            f.write("# Test OBJ file\n")
            f.write(f"# Generated from {path_to_stl}\n")

        with open(txt_file, 'w') as f:
            f.write(f"Source: {path_to_stl}\n")
            f.write(f"Output: {obj_file}\n")
            f.write("Status: Success\n")

        print(f"Created: {obj_file}")
        print(f"Created: {txt_file}")

        return 0

    except Exception as e:
        print(f"Error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())

