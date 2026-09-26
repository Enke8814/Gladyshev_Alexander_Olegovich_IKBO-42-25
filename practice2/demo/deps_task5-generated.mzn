% Модель сгенерирована автоматически по метаданным пакетов.
% 0 означает, что пакет не установлен.

% dropdown: версии 1.8.0, 2.0.0, 2.1.0, 2.2.0, 2.3.0
array[0..5] of string: ver_dropdown = array1d(0..5, ["не установлен", "1.8.0", "2.0.0", "2.1.0", "2.2.0", "2.3.0"]);
var 0..5: dropdown;

% icons: версии 1.0.0, 2.0.0
array[0..2] of string: ver_icons = array1d(0..2, ["не установлен", "1.0.0", "2.0.0"]);
var 0..2: icons;

% menu: версии 1.0.0, 1.1.0, 1.2.0, 1.3.0, 1.4.0, 1.5.0
array[0..6] of string: ver_menu = array1d(0..6, ["не установлен", "1.0.0", "1.1.0", "1.2.0", "1.3.0", "1.4.0", "1.5.0"]);
var 0..6: menu;

% root: версии 1.0.0
array[0..1] of string: ver_root = array1d(0..1, ["не установлен", "1.0.0"]);
var 0..1: root;

% Корневой пакет root установлен всегда.
constraint root = 1;

% Зависимости: выбор версии пакета ограничивает версии его зависимостей.
% dropdown 1.8.0 зависит от icons ^1.0.0
constraint dropdown = 1 -> icons in {1};
% dropdown 2.0.0 зависит от icons ^2.0.0
constraint dropdown = 2 -> icons in {2};
% dropdown 2.1.0 зависит от icons ^2.0.0
constraint dropdown = 3 -> icons in {2};
% dropdown 2.2.0 зависит от icons ^2.0.0
constraint dropdown = 4 -> icons in {2};
% dropdown 2.3.0 зависит от icons ^2.0.0
constraint dropdown = 5 -> icons in {2};
% menu 1.0.0 зависит от dropdown ^1.8.0
constraint menu = 1 -> dropdown in {1};
% menu 1.1.0 зависит от dropdown ^2.0.0
constraint menu = 2 -> dropdown in {2, 3, 4, 5};
% menu 1.2.0 зависит от dropdown ^2.0.0
constraint menu = 3 -> dropdown in {2, 3, 4, 5};
% menu 1.3.0 зависит от dropdown ^2.0.0
constraint menu = 4 -> dropdown in {2, 3, 4, 5};
% menu 1.4.0 зависит от dropdown ^2.0.0
constraint menu = 5 -> dropdown in {2, 3, 4, 5};
% menu 1.5.0 зависит от dropdown ^2.0.0
constraint menu = 6 -> dropdown in {2, 3, 4, 5};
% root 1.0.0 зависит от icons ^1.0.0
constraint root = 1 -> icons in {1};
% root 1.0.0 зависит от menu ^1.0.0
constraint root = 1 -> menu in {1, 2, 3, 4, 5, 6};

% Пакет ставится только если его требует установленный пакет.
constraint (dropdown >= 1) <-> (menu = 1 \/ menu = 2 \/ menu = 3 \/ menu = 4 \/ menu = 5 \/ menu = 6);
constraint (icons >= 1) <-> (dropdown = 1 \/ dropdown = 2 \/ dropdown = 3 \/ dropdown = 4 \/ dropdown = 5 \/ root = 1);
constraint (menu >= 1) <-> (root = 1);

% При прочих равных выбираются более свежие версии.
solve maximize dropdown + icons + menu + root;

output [
  "dropdown = ", ver_dropdown[fix(dropdown)], "\n",
  "icons = ", ver_icons[fix(icons)], "\n",
  "menu = ", ver_menu[fix(menu)], "\n",
  "root = ", ver_root[fix(root)], "\n"
];
