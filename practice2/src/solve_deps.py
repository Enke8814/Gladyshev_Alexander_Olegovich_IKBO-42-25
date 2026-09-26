#!/usr/bin/env python3
"""Задача 7. Разрешение зависимостей пакетов в общей форме.

Метаданные пакетов задаются структурой данных (словарём), а система ограничений
для MiniZinc строится по ним автоматически. Это отличает задачу от предыдущих,
где ограничения выписывались вручную под конкретный пример.

Формат метаданных:
    {"имя пакета": {"версия": {"зависимость": "ограничение", ...}, ...}, ...}

Поддерживаемые ограничения: ^X.Y.Z, >=X.Y.Z, >X.Y.Z, <=X.Y.Z, <X.Y.Z, =X.Y.Z.

Использование: ./solve_deps.py <файл_метаданных.json> [корневой_пакет]
"""

import json
import subprocess
import sys


def parse(version):
    """Строка версии в кортеж чисел для сравнения: '1.10.0' -> (1, 10, 0)."""
    return tuple(int(part) for part in version.split("."))


def matches(version, constraint):
    """Проверка, удовлетворяет ли версия ограничению semver."""
    v = parse(version)
    c = constraint.strip()

    if c.startswith("^"):
        low = parse(c[1:])
        # Карет запрещает менять старший ненулевой разряд.
        if low[0] > 0:
            high = (low[0] + 1, 0, 0)
        elif low[1] > 0:
            high = (0, low[1] + 1, 0)
        else:
            high = (0, 0, low[2] + 1)
        return low <= v < high
    if c.startswith(">="):
        return v >= parse(c[2:])
    if c.startswith("<="):
        return v <= parse(c[2:])
    if c.startswith(">"):
        return v > parse(c[1:])
    if c.startswith("<"):
        return v < parse(c[1:])
    if c.startswith("="):
        return v == parse(c[1:])
    return v == parse(c)


def build_model(meta, root):
    """Генерация модели MiniZinc по метаданным."""
    # Версии каждого пакета нумеруются по возрастанию начиная с 1.
    # Ноль означает "пакет не установлен".
    order = {
        pkg: sorted(versions, key=parse)
        for pkg, versions in meta.items()
    }
    index = {
        pkg: {ver: i + 1 for i, ver in enumerate(vers)}
        for pkg, vers in order.items()
    }

    lines = []
    lines.append("% Модель сгенерирована автоматически по метаданным пакетов.")
    lines.append("% 0 означает, что пакет не установлен.")
    lines.append("")

    # Объявление переменных и таблиц названий версий.
    for pkg in sorted(meta):
        n = len(order[pkg])
        names = ", ".join('"%s"' % v for v in ["не установлен"] + order[pkg])
        lines.append("%% %s: версии %s" % (pkg, ", ".join(order[pkg])))
        lines.append("array[0..%d] of string: ver_%s = array1d(0..%d, [%s]);"
                     % (n, pkg, n, names))
        lines.append("var 0..%d: %s;" % (n, pkg))
        lines.append("")

    # Корневой пакет установлен всегда.
    lines.append("%% Корневой пакет %s установлен всегда." % root)
    lines.append("constraint %s = %d;" % (root, index[root][order[root][0]]))
    lines.append("")

    # Для каждой версии каждого пакета — ограничения на её зависимости.
    lines.append("% Зависимости: выбор версии пакета ограничивает версии его зависимостей.")
    for pkg in sorted(meta):
        for ver in order[pkg]:
            for dep, constraint in sorted(meta[pkg][ver].items()):
                allowed = [
                    index[dep][dv] for dv in order[dep]
                    if matches(dv, constraint)
                ]
                if not allowed:
                    lines.append("%% %s %s требует %s %s — подходящих версий нет"
                                 % (pkg, ver, dep, constraint))
                    lines.append("constraint %s != %d;" % (pkg, index[pkg][ver]))
                    continue
                allowed_str = ", ".join(str(a) for a in allowed)
                lines.append("%% %s %s зависит от %s %s"
                             % (pkg, ver, dep, constraint))
                lines.append("constraint %s = %d -> %s in {%s};"
                             % (pkg, index[pkg][ver], dep, allowed_str))
    lines.append("")

    # Пакет установлен тогда и только тогда, когда его требует кто-то другой.
    lines.append("% Пакет ставится только если его требует установленный пакет.")
    for pkg in sorted(meta):
        if pkg == root:
            continue
        causes = []
        for other in sorted(meta):
            for ver in order[other]:
                if pkg in meta[other][ver]:
                    causes.append("%s = %d" % (other, index[other][ver]))
        if causes:
            lines.append("constraint (%s >= 1) <-> (%s);"
                         % (pkg, " \\/ ".join(causes)))
        else:
            lines.append("constraint %s = 0;" % pkg)
    lines.append("")

    # Предпочтение более свежим версиям.
    lines.append("% При прочих равных выбираются более свежие версии.")
    lines.append("solve maximize %s;" % " + ".join(sorted(meta)))
    lines.append("")

    out = [
        '  "%s = ", ver_%s[fix(%s)], "\\n"' % (pkg, pkg, pkg)
        for pkg in sorted(meta)
    ]
    lines.append("output [")
    lines.append(",\n".join(out))
    lines.append("];")

    return "\n".join(lines) + "\n"


def main():
    if len(sys.argv) < 2:
        print("Использование: %s <файл_метаданных.json> [корневой_пакет]"
              % sys.argv[0], file=sys.stderr)
        return 1

    with open(sys.argv[1], encoding="utf-8") as f:
        meta = json.load(f)

    root = sys.argv[2] if len(sys.argv) > 2 else "root"
    model = build_model(meta, root)

    model_path = sys.argv[1].rsplit(".", 1)[0] + "-generated.mzn"
    with open(model_path, "w", encoding="utf-8") as f:
        f.write(model)
    print("Модель сгенерирована: %s" % model_path)
    print()

    result = subprocess.run(["minizinc", model_path],
                            capture_output=True, text=True)
    print(result.stdout, end="")
    if result.stderr:
        print(result.stderr, end="", file=sys.stderr)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
