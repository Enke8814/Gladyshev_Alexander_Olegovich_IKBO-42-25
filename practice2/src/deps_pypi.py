#!/usr/bin/env python3
"""Задача 3. Генерация graphviz-кода (DOT) для дерева зависимостей пакета PyPI.

Зависимости берутся из метаданных пакета: PyPI отдаёт их по HTTP в JSON,
поле info.requires_dist. Обход идёт вглубь до заданной глубины.

Использование: ./deps_pypi.py [пакет] [глубина]
"""

import json
import re
import sys
import urllib.request

ROOT = (sys.argv[1] if len(sys.argv) > 1 else "matplotlib").lower()
MAX_DEPTH = int(sys.argv[2]) if len(sys.argv) > 2 else 2


def dependencies(pkg):
    """Прямые зависимости пакета без необязательных (extra) наборов."""
    url = "https://pypi.org/pypi/{}/json".format(pkg)
    try:
        with urllib.request.urlopen(url, timeout=20) as resp:
            data = json.load(resp)
    except Exception:
        return []

    result = []
    for item in data["info"].get("requires_dist") or []:
        if "extra ==" in item:
            continue
        name = re.split(r"[\s<>=!~;\[(]", item, maxsplit=1)[0]
        if name:
            result.append(name.lower())
    return sorted(set(result))


edges = set()
visited = set()


def walk(pkg, depth):
    if depth > MAX_DEPTH or pkg in visited:
        return
    visited.add(pkg)
    for dep in dependencies(pkg):
        edges.add((pkg, dep))
        walk(dep, depth + 1)


walk(ROOT, 1)

print("digraph deps {")
print('    rankdir=LR;')
print('    node [shape=box, style=rounded, fontname="DejaVu Sans", fontsize=11];')
print('    "{}" [style="rounded,filled", fillcolor="#cfe8ff"];'.format(ROOT))
for src, dst in sorted(edges):
    print('    "{}" -> "{}";'.format(src, dst))
print("}")
