#!/bin/bash
# Задача 6. Проверка наличия комментария в первой строке файлов .c, .js, .py.
# Использование: ./task6.sh [каталог]

set -euo pipefail

dir="${1:-.}"

if [ ! -d "$dir" ]; then
    echo "Ошибка: '$dir' не каталог" >&2
    exit 1
fi

find "$dir" -type f \( -name '*.c' -o -name '*.js' -o -name '*.py' \) -print0 \
| while IFS= read -r -d '' file; do
    first_line=$(head -n 1 "$file")

    case "$file" in
        *.py) pattern='^[[:space:]]*#' ;;         # Python: # комментарий
        *)    pattern='^[[:space:]]*(//|/\*)' ;;  # C/JS: // или /* */
    esac

    if printf '%s\n' "$first_line" | grep -Eq "$pattern"; then
        echo "есть комментарий : $file"
    else
        echo "нет комментария  : $file"
    fi
done
