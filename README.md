# Rooster

Rooster — offline-first task manager на Flutter. Приложение помогает вести задачи и списки, планировать дела, получать напоминания, работать с вложениями и использовать экран «Решения», который объясняет, какие задачи можно делать сейчас и что их блокирует.

## Возможности

- Задачи, списки задач, теги, приоритеты и закрепление.
- Даты, интервалы времени, задачи на весь день, разовые и регулярные напоминания.
- Вложения изображений и история изменений задачи.
- Роли для совместной работы: владелец, исполнитель, наблюдатель.
- Offline-first хранение в Hive с очередью синхронизации.
- Облачная синхронизация через выбранную стратегию авторизации и backend-сборку.
- Экран «Решения»: готовые задачи на сегодня, заблокированные задачи с причинами, бюджет и склад материалов.
- Профиль, команды, настройки темы и локали.

## Стек

| Область | Технологии |
| --- | --- |
| UI | Flutter, Dart |
| Архитектура экранов | Elementary, WidgetModel, Model |
| Навигация | auto_route |
| DI / состояние | provider, ValueNotifier |
| Локальное хранение | Hive, SharedPreferences, flutter_secure_storage |
| Сеть и интеграции | Dio, Retrofit, Appwrite, Supabase, Firebase/HMS ветки |
| Уведомления | flutter_local_notifications |
| Генерация | build_runner, freezed, json_serializable, theme_tailor, Mason |
| Анализ | very_good_analysis |

## Структура

```text
lib/
├── api/            # REST-клиенты и сетевые DTO
├── app_routing/    # Константы путей
├── common/         # Общие утилиты
├── config/         # Environment, AppConfig, env-настройки
├── core/           # Базовая архитектура, sync, analytics, failures
├── features/       # Вертикальные фичи приложения
├── integration/    # Внешние интеграции
├── persistence/    # Хранилища
├── uikit/          # Дизайн-система
└── util/           # Прикладные утилиты
```

Основные фичи:

- `features/tasks` — задачи, списки, детали, создание, decision-система.
- `features/planning` — планирование.
- `features/profile` — профиль, команды, участники.
- `features/auth` — авторизация и выбор backend-стратегии.
- `features/settings` — настройки.
- `features/navigation` — граф `auto_route`.
- `features/app` — корневой flow и app scope.

## Запуск

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Для Windows MSIX:

```powershell
dart run msix:create
```

## Документация

- [Функциональная спецификация](docs/FUNCTIONAL_SPEC.md)
- [Описание экранов](docs/DESCRIPTION_APP.md)
- [Архитектура](docs/ARCHITECTURE.md)
- [Технический документ](docs/TECHNICAL_PROJECT_DOCUMENT.md)
- [Decision system](docs/DECISION_SYSTEM_IMPLEMENTATION.md)
- [Appwrite sync tasks](docs/APPWRITE_FULL_SYNC_TASKS.md)
