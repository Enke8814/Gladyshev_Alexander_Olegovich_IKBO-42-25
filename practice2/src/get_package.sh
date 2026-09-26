#!/bin/bash
# Задача 1. Получение пакета напрямую из репозитория PyPI, без менеджера пакетов.
# PyPI отдаёт метаданные по HTTP в формате JSON, оттуда берём прямую ссылку
# на архив с исходниками (sdist) и скачиваем его обычным curl.
# Использование: ./get_package.sh [имя_пакета]

set -euo pipefail

pkg="${1:-matplotlib}"
meta=$(mktemp)

curl -s "https://pypi.org/pypi/${pkg}/json" -o "$meta"

url=$(python3 -c "
import json
d = json.load(open('$meta'))
print(next(u['url'] for u in d['urls'] if u['packagetype'] == 'sdist'))
")

echo "Прямая ссылка на архив: $url"
curl -sL -O "$url"
ls -lh "$(basename "$url")"

rm -f "$meta"
