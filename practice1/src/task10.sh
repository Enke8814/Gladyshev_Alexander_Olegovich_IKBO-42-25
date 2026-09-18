#!/bin/bash
# Задача 10. Вывод имён всех пустых текстовых файлов в указанной директории.
# Использование: ./task10.sh <каталог> [расширение]   (по умолчанию txt)

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Использование: $0 <каталог> [расширение]" >&2
    exit 1
fi

dir="$1"
ext="${2:-txt}"
ext="${ext#.}"

if [ ! -d "$dir" ]; then
    echo "Ошибка: '$dir' не каталог" >&2
    exit 1
fi

# -empty — файл нулевого размера; -maxdepth 1 — только указанный каталог.
find "$dir" -maxdepth 1 -type f -name "*.${ext}" -empty -printf '%f\n' | sort
