#!/bin/bash
# Задача 1. Отсортированный по алфавиту список имён пользователей из /etc/passwd.
# Имя пользователя — первое поле строки, разделитель ':'.

set -euo pipefail

PASSWD_FILE="${1:-/etc/passwd}"

grep -o '^[^:]\+' "$PASSWD_FILE" | sort
