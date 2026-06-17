# Тесты: разделение слоёв (OSMOST)

Документ закрепляет правила из **раздела 2** чеклиста [TESTING_CHECKLIST.md](../docs/TESTING_CHECKLIST.md). Подробнее о структуре каталогов — [TESTING.md](../docs/TESTING.md).

---

## Назначение папок под фичу

| Папка теста | Что здесь проверяем | Импорты из прод-кода |
|-------------|---------------------|----------------------|
| `test/features/<f>/domain/` | Entity, use case, доменные правила | `lib/features/<f>/domain/`, общие типы без UI |
| `test/features/<f>/data/` | Репозитории, мапперы, DTO | `lib/features/<f>/data/`, контракты domain при необходимости ([TESTING_DATA_UNIT.md](../docs/TESTING_DATA_UNIT.md)) |
| `test/features/<f>/presentation/` | Виджеты, экраны, WM (с фейковой model) | `lib/features/<f>/presentation/`, `uikit`, тестовые фейки |

---

## Правила импортов по типу теста

### Domain-тест (`.../domain/*_test.dart`)

- **Разрешено:** `package:flutter/foundation.dart` (например `kDebugMode`) — только если это уже допустимо в domain прод-кода; иначе избегать.
- **Запрещено:** импорт из `.../presentation/`, `Widget`, `BuildContext`, `Material`, `flutter_test` для `WidgetTester` (для unit domain не нужен).
- **Запрещено:** конкретные классы репозиториев из `.../data/` — только **интерфейсы** из domain и тестовые **Fake**, реализующие их в том же файле теста или в `test/helpers/`.

### Data-тест (`.../data/*_test.dart`)

- **Разрешено:** domain-контракты, DTO, мапперы, фейки HTTP/хранилища.
- **Не использовать без необходимости:** экраны, `WidgetModel`, `MaterialApp`. Если тесту нужен только `WidgetsFlutterBinding.ensureInitialized()` — минимальный импорт, без построения UI.
- **Запрещено:** реальные сетевые вызовы и реальный Modbus; подмена через fake/mock.

### Presentation-тест (`.../presentation/*_test.dart`)

- **Разрешено:** `flutter_test`, виджеты фичи, `uikit`, тема, тестовый роутер/Provider по образцу приложения.
- **Запрещено:** прямые вызовы `ModbusControllersRegistry`, сборка `SdkConfig` для бизнес-сценария, реальный файловый доступ без изолированной директории — как в правилах слоёв прод-кода.
- **Зависимости UI:** подмена через **фейковую model** (интерфейс из presentation), а не через репозиторий из data слоя.

---

## Данные в проверках UI

- В **проверках отображения** (`expect`, `find`) используйте поля **entity** или тестовые объекты, собранные как entity (через конструктор/factory).
- **Не** подставляйте в виджет DTO из `data` и не проверяйте «как на сервере», если на экране по архитектуре должен быть entity — путь: DTO → mapper → entity остаётся в data/domain; в presentation-тесте достаточно готовой entity.

---

## Modbus SDK

Тесты в `test/modbus/` не заменяют правила выше для фич: это отдельный модуль SDK. Правила импортов соответствуют слою SDK (`lib/modbus/...`), без подмешивания экранов приложения.

---

## Как проверить перед коммитом

1. Откройте файл `*_test.dart` и просмотрите блок `import` — он должен соответствовать таблице для типа папки.
2. Сверьтесь с [TESTING_CHECKLIST.md](../docs/TESTING_CHECKLIST.md), раздел **2. Разделение слоёв**.
