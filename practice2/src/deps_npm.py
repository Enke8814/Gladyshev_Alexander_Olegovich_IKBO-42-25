#!/usr/bin/env python3
"""Задача 3. Генерация graphviz-кода (DOT) для дерева зависимостей пакета npm.

Реестр npm отдаёт метаданные по HTTP в JSON, зависимости лежат в
versions[<последняя версия>].dependencies. Обход идёт вглубь до заданной глубины.

Использование: ./deps_npm.py [пакет] [глубина]
"""

import json
import sys
import urllib.parse
import urllib.request

ROOT = sys.argv[1] if len(sys.argv) > 1 else "express"
MAX_DEPTH = int(sys.argv[2]) if len(sys.argv) > 2 else 2


def dependencies(pkg):
    """Прямые зависимости последней версии пакета (без devDependencies)."""
    url = "https://registry.npmjs.org/{}".format(urllib.parse.quote(pkg, safe="@"))
    try:
        with urllib.request.urlopen(url, timeout=20) as resp:
            data = json.load(resp)
    except Exception:
        return []

    try:
        latest = data["dist-tags"]["latest"]
        deps = data["versions"][latest].get("dependencies") or {}
    except KeyError:
        return []
    return sorted(deps.keys())


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
