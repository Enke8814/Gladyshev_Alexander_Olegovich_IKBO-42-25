#!/bin/bash
# Задача 2. Пять наибольших номеров протоколов из /etc/protocols.
# Формат файла: <имя> <номер> <алиасы...>; выводим "<номер> <имя>".

set -euo pipefail

PROTO_FILE="${2:-/etc/protocols}"
TOP="${1:-5}"

grep -v '^[[:space:]]*#' "$PROTO_FILE" \
    | awk 'NF >= 2 { printf "%-5s %s\n", $2, $1 }' \
    | sort -k1,1nr \
    | head -n "$TOP"
