# Отчёт по приложению Rooster

## 1. Назначение

Rooster — offline-first task manager. Приложение предназначено для личного и совместного ведения задач: пользователь создаёт списки, задачи, напоминания, вложения, назначает исполнителей и наблюдателей, а также получает подсказки на экране «Решения».

## 2. Запуск приложения

Цепочка запуска:

1. `lib/main.dart` создаёт `Environment(BuildType.dev)` и вызывает `run`.
2. `lib/runner.dart` инициализирует Flutter, системный UI, `.env`, затем создаёт `AppScope`.
3. `AppScopeRegister` поднимает Hive, SharedPreferences, secure storage, auth backend, sync manager, репозитории и use case.
4. `AppFlow` предоставляет зависимости через Provider.
5. Корневой `App` запускает `MaterialApp.router`.

## 3. Верхнеуровневая структура

| Каталог | Назначение |
| --- | --- |
| `lib/api` | Сетевые клиенты, DTO и API-утилиты. |
| `lib/app_routing` | Константы сегментов маршрутов. |
| `lib/common` | Общие утилиты, логирование, snack queue. |
| `lib/config` | Environment, AppConfig и env-конфигурация. |
| `lib/core` | Базовая архитектура, sync, analytics, failures. |
| `lib/features` | Фичи приложения. |
| `lib/integration` | Интеграции с внешними сервисами. |
| `lib/persistence` | Реализации локальных хранилищ. |
| `lib/uikit` | Дизайн-система приложения. |
| `lib/util` | Прикладные расширения и утилиты. |

## 4. Фичи

| Фича | Ответственность |
| --- | --- |
| `app` | Корневой flow, shell, scope. |
| `auth` | Авторизация и backend-стратегии. |
| `tasks` | Задачи, списки, создание, детали, history, decision-система. |
| `planning` | Планирование. |
| `profile` | Профиль пользователя, команды и участники. |
| `settings` | Настройки. |
| `theme_mode` | Режим темы. |
| `locale_mode` | Локаль. |
| `navigation` | Граф `auto_route`. |
| `dev_panel` | Диагностика и внутренние инструменты. |

## 5. Данные и синхронизация

Основной локальный источник данных — Hive. На старте открываются боксы:

- `tasks_v1`
- `task_lists_v1`
- `planning_v1`
- `sync_queue_v1`
- `task_changes_v1`
- `task_decision_v1`

Изменения задач и списков пишутся локально и ставятся в очередь синхронизации. `SyncManagerImpl` отправляет операции через активный remote executor, выбранный backend-сборкой авторизации.

## 6. Decision-система

Decision-система использует поля задачи:

- `importance`
- `complexity`
- `estimatedCost`
- `materialRequirements`
- `dependencyTaskIds`

Основные сценарии:

- список готовых задач на сегодня;
- список заблокированных задач с причинами;
- бюджет и склад материалов;
- расчёт выполнимости и score через доменные use case.

## 7. Навигация

Навигация построена на `auto_route`. Основной граф находится в `lib/features/navigation/app_router.dart`.

Главный flow содержит вкладки:

- задачи;
- списки;
- планирование;
- решения;
- профиль.

## 8. Архитектурные правила

- Фичи разделяются на `data`, `domain`, `presentation`.
- Presentation работает через `Screen + WidgetModel + Model`.
- Domain не зависит от Flutter UI, API-клиентов и конкретных хранилищ.
- Data реализует репозитории, DTO, мапперы и gateway.
- UI-строки проходят через локализацию и presentation-обёртки.
- Переходы выполняются типизированными route-классами.

## 9. Итог

Rooster — Flutter-приложение с чистой архитектурой, локальным offline-first хранением, синхронизацией через очередь операций и отдельным доменным контуром для объяснимого выбора задач.
