% Модель сгенерирована автоматически по метаданным пакетов.
% 0 означает, что пакет не установлен.

% foo: версии 1.0.0, 1.1.0
array[0..2] of string: ver_foo = array1d(0..2, ["не установлен", "1.0.0", "1.1.0"]);
var 0..2: foo;

% left: версии 1.0.0
array[0..1] of string: ver_left = array1d(0..1, ["не установлен", "1.0.0"]);
var 0..1: left;

% right: версии 1.0.0
array[0..1] of string: ver_right = array1d(0..1, ["не установлен", "1.0.0"]);
var 0..1: right;

% root: версии 1.0.0
array[0..1] of string: ver_root = array1d(0..1, ["не установлен", "1.0.0"]);
var 0..1: root;

% shared: версии 1.0.0, 2.0.0
array[0..2] of string: ver_shared = array1d(0..2, ["не установлен", "1.0.0", "2.0.0"]);
var 0..2: shared;

% target: версии 1.0.0, 2.0.0
array[0..2] of string: ver_target = array1d(0..2, ["не установлен", "1.0.0", "2.0.0"]);
var 0..2: target;

% Корневой пакет root установлен всегда.
constraint root = 1;

% Зависимости: выбор версии пакета ограничивает версии его зависимостей.
% foo 1.1.0 зависит от left ^1.0.0
constraint foo = 2 -> left in {1};
% foo 1.1.0 зависит от right ^1.0.0
constraint foo = 2 -> right in {1};
% left 1.0.0 зависит от shared >=1.0.0
constraint left = 1 -> shared in {1, 2};
% right 1.0.0 зависит от shared <2.0.0
constraint right = 1 -> shared in {1};
% root 1.0.0 зависит от foo ^1.0.0
constraint root = 1 -> foo in {1, 2};
% root 1.0.0 зависит от target ^2.0.0
constraint root = 1 -> target in {2};
% shared 1.0.0 зависит от target ^1.0.0
constraint shared = 1 -> target in {1};

% Пакет ставится только если его требует установленный пакет.
constraint (foo >= 1) <-> (root = 1);
constraint (left >= 1) <-> (foo = 2);
constraint (right >= 1) <-> (foo = 2);
constraint (shared >= 1) <-> (left = 1 \/ right = 1);
constraint (target >= 1) <-> (root = 1 \/ shared = 1);

% При прочих равных выбираются более свежие версии.
solve maximize foo + left + right + root + shared + target;

output [
  "foo = ", ver_foo[fix(foo)], "\n",
  "left = ", ver_left[fix(left)], "\n",
  "right = ", ver_right[fix(right)], "\n",
  "root = ", ver_root[fix(root)], "\n",
  "shared = ", ver_shared[fix(shared)], "\n",
  "target = ", ver_target[fix(target)], "\n"
];
