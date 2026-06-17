# Архитектура Rooster

## Обзор

Rooster — Flutter-приложение для управления задачами. Архитектура построена вокруг feature-first структуры, Clean Architecture и паттерна Elementary: экран состоит из `Screen`, `WidgetModel` и `Model`.

Главный принцип: UI не ходит напрямую в инфраструктуру. Пользовательский сценарий проходит через presentation model, domain-контракт/use case и data-реализацию.

## Технологический стек

- Flutter / Dart.
- Elementary для экранов.
- Provider для DI и глобального состояния.
- AutoRoute для типизированной навигации.
- Hive для offline-first данных.
- SharedPreferences для простых настроек.
- FlutterSecureStorage для токенов и PIN.
- Dio / Retrofit для HTTP.
- Appwrite, Supabase, Firebase/HMS ветки для auth/sync интеграций.
- flutter_local_notifications для напоминаний.
- theme_tailor для дизайн-токенов.
- very_good_analysis для статического анализа.

## Слои

```text
Presentation
  Screen / Widget / WidgetModel / Model
        ↓
Domain
  Entity / Repository interface / Gateway interface / Use case
        ↓
Data
  Repository implementation / DTO / Mapper / Storage / Remote executor
        ↓
Infrastructure
  Hive / SharedPreferences / SecureStorage / HTTP / cloud SDK / notifications
```

## Структура `lib`

```text
lib/
├── api/
├── app_routing/
├── common/
├── config/
├── core/
├── features/
├── gen/
├── integration/
├── l10n/
├── persistence/
├── uikit/
└── util/
```

## Фичи

```text
features/<feature>/
├── data/
│   ├── repositories/
│   ├── storage/
│   ├── gateways/
│   └── mappers/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── gateways/
│   └── use_cases/
└── presentation/
    ├── screens/
    ├── strings/
    └── widgets/
```

Текущие основные фичи:

- `app`
- `auth`
- `dev_panel`
- `locale_mode`
- `navigation`
- `planning`
- `profile`
- `settings`
- `tasks`
- `theme_mode`

## Запуск

```text
main.dart
  ↓
runner.dart
  ↓
AppScopeRegister.createScope
  ↓
AppFlow
  ↓
App
  ↓
MaterialApp.router
```

`AppScopeRegister` отвечает за создание инфраструктуры:

- инициализация Hive;
- открытие боксов;
- создание SharedPreferences и secure storage;
- выбор auth backend strategy;
- создание репозиториев;
- создание sync queue и sync manager;
- регистрация use case;
- настройка уведомлений;
- возврат `AppScope`.

## Локальное хранение

Основные Hive-боксы:

- `tasks_v1`
- `task_lists_v1`
- `planning_v1`
- `sync_queue_v1`
- `task_changes_v1`
- `task_decision_v1`

Данные задач и списков сохраняются локально в первую очередь. Синхронизация с облаком выполняется отдельно через очередь операций.

## Синхронизация

Контур синхронизации:

```text
Repository
  ↓ локальная запись
Hive
  ↓ операция
ISyncQueue
  ↓ requestSync
SyncManagerImpl
  ↓
ISyncRemoteExecutor
  ↓
Cloud backend
```

При сетевой ошибке операция остаётся в очереди и повторяется позже. Backend executor выбирается на старте через auth assembly.

## Decision-система

Decision-система находится в `features/tasks` и состоит из:

- доменных сущностей задачи, бюджета и материалов;
- калькулятора выполнимости;
- политики scoring;
- use case для готовых и заблокированных задач;
- UI экранов `Today`, `Blocked`, `Resources`.

`TaskStatusEntity` описывает факт выполнения. Выполнимость задачи считается отдельно и не подменяет статус задачи.

## Навигация

Маршруты объявлены в `features/navigation/app_router.dart`, сегменты путей — в `app_routing/app_route_paths.dart`.

Правило проекта: для штатной навигации использовать типизированные route-классы, а не строковые пути.

## UI

- Экран наследуется от базового виджета проекта.
- Логика состояния и действий находится в WidgetModel.
- Данные загружаются через Model.
- Изменяемое состояние в presentation хранится в `ValueNotifier`.
- Списочные состояния используют `UnionStateListenable` и общие body-виджеты там, где это подходит.
- Пользовательские строки берутся через presentation-классы `*Strings`.

## Тестирование

Рекомендуемые уровни:

- unit-тесты для domain use case и кодеков;
- unit-тесты для repositories/storage;
- widget-тесты для сложных UI-состояний;
- интеграционные сценарии для offline → online sync.

## Производительность и устойчивость

- UI получает данные из локального хранилища быстро и независимо от сети.
- Синхронизация выполняется фоном.
- Напоминания планируются через отдельный gateway.
- Ошибки инфраструктуры логируются через общий logger.
- После `await` в presentation нужно учитывать жизненный цикл WM/виджета.
