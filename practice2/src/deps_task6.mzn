% Задача 6. Разрешение зависимостей для набора данных из задания.
%
%   root 1.0.0   зависит от foo ^1.0.0 и target ^2.0.0
%   foo 1.1.0    зависит от left ^1.0.0 и right ^1.0.0
%   foo 1.0.0    зависимостей не имеет
%   left 1.0.0   зависит от shared >=1.0.0
%   right 1.0.0  зависит от shared <2.0.0
%   shared 2.0.0 зависимостей не имеет
%   shared 1.0.0 зависит от target ^1.0.0
%   target 2.0.0 и 1.0.0 зависимостей не имеют
%
% Кодировка версий порядковыми номерами; 0 означает "пакет не установлен".
%   foo:    1 = 1.0.0, 2 = 1.1.0
%   left:   0 = не установлен, 1 = 1.0.0
%   right:  0 = не установлен, 1 = 1.0.0
%   shared: 0 = не установлен, 1 = 1.0.0, 2 = 2.0.0
%   target: 1 = 1.0.0, 2 = 2.0.0

array[1..2] of string: foo_ver    = ["1.0.0", "1.1.0"];
array[0..1] of string: opt_ver    = array1d(0..1, ["не установлен", "1.0.0"]);
array[0..2] of string: shared_ver = array1d(0..2, ["не установлен", "1.0.0", "2.0.0"]);
array[1..2] of string: target_ver = ["1.0.0", "2.0.0"];

var 1..2: foo;
var 0..1: left;
var 0..1: right;
var 0..2: shared;
var 1..2: target;

% root требует target ^2.0.0 — подходит только версия 2.0.0.
constraint target = 2;

% foo 1.1.0 требует left ^1.0.0 и right ^1.0.0.
% Обратное тоже верно: без foo 1.1.0 эти пакеты никому не нужны и не ставятся.
constraint (left >= 1) <-> (foo = 2);
constraint (right >= 1) <-> (foo = 2);

% shared ставится тогда и только тогда, когда его требует left или right.
constraint (shared >= 1) <-> (left >= 1 \/ right >= 1);

% left 1.0.0 требует shared >=1.0.0 — подходит любая версия shared.
constraint left >= 1 -> shared >= 1;

% right 1.0.0 требует shared <2.0.0 — подходит только 1.0.0.
constraint right >= 1 -> shared = 1;

% shared 1.0.0 требует target ^1.0.0.
constraint shared = 1 -> target = 1;

% При прочих равных менеджер пакетов берёт более свежие версии.
solve maximize foo * 10 + target;

output [
  "foo    = ", foo_ver[fix(foo)], "\n",
  "left   = ", opt_ver[fix(left)], "\n",
  "right  = ", opt_ver[fix(right)], "\n",
  "shared = ", shared_ver[fix(shared)], "\n",
  "target = ", target_ver[fix(target)], "\n"
];
