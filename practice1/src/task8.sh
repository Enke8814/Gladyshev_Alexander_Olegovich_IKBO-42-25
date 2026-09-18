#!/bin/bash
# Задача 8. Архивация в tar всех файлов с заданным расширением.
# Использование: ./task8.sh <каталог> <расширение> [имя_архива]

set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Использование: $0 <каталог> <расширение> [имя_архива]" >&2
    exit 1
fi

dir="$1"
ext="${2#.}"                      # разрешаем и "txt", и ".txt"
archive="${3:-${ext}_files.tar}"

if [ ! -d "$dir" ]; then
    echo "Ошибка: '$dir' не каталог" >&2
    exit 1
fi

# -print0 / --null: корректно работаем с пробелами в именах файлов.
find "$dir" -type f -name "*.${ext}" -print0 \
    | tar --null -cf "$archive" -T -

echo "Создан архив: $archive"
tar -tf "$archive"
