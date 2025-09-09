# Соберите Docker образ
docker build -t windows-builder .

# Запустите контейнер и выполните сборку
docker run -it --rm \
  -v $(pwd):/app \
  -v $(pwd)/output:/app/dist \
  windows-builder \
  ./build_windows.sh

