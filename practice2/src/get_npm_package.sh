#!/bin/bash
# Задача 2. Получение пакета напрямую из реестра npm, без менеджера пакетов.
# registry.npmjs.org отдаёт метаданные пакета по HTTP в формате JSON.
# В поле dist.tarball лежит прямая ссылка на архив .tgz.
# Использование: ./get_npm_package.sh [имя_пакета]

set -euo pipefail

pkg="${1:-express}"
meta=$(mktemp)

curl -s "https://registry.npmjs.org/${pkg}" -o "$meta"

url=$(python3 -c "
import json
d = json.load(open('$meta'))
latest = d['dist-tags']['latest']
print(d['versions'][latest]['dist']['tarball'])
")

echo "Прямая ссылка на архив: $url"
curl -sL -O "$url"
ls -lh "$(basename "$url")"

rm -f "$meta"
