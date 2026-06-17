# Технический документ Rooster

Документ фиксирует технические правила проекта Rooster: структуру каталогов, границы слоёв, навигацию, DI, хранение данных и порядок добавления новых фич.

## 1. Назначение

Rooster — offline-first task manager. Основные продуктовые области:

- задачи и списки;
- планирование;
- напоминания;
- профиль и команды;
- синхронизация;
- decision-система для выбора выполнимых задач.

## 2. Базовый стек

| Область | Решение |
| --- | --- |
| UI | Flutter |
| Архитектура экранов | Elementary |
| Навигация | auto_route |
| DI | provider |
| Локальные данные | Hive |
| Простые настройки | SharedPreferences |
| Секреты | flutter_secure_storage |
| HTTP | Dio / Retrofit |
| Immutable / JSON | freezed / json_serializable |
| Темы | theme_tailor |
| Состояния списков | union_state |
| Генерация | build_runner / Mason |

## 3. Структура

```text
lib/
├── api/
├── app_routing/
├── common/
├── config/
├── core/
├── features/
├── integration/
├── persistence/
├── uikit/
└── util/
```

## 4. Границы слоёв

### Domain

Содержит:

- `*_entity.dart`;
- `i_*_repository.dart`;
- `i_*_gateway.dart`;
- use case;
- чистые сервисы и валидаторы.

Domain не импортирует Flutter UI, конкретные SDK, Hive, SharedPreferences, Dio и presentation/data реализации.

### Data

Содержит:

- реализации репозиториев;
- DTO;
- мапперы;
- gateway;
- работу с локальным хранилищем и удалёнными API.

Data не содержит виджетов, `BuildContext` и WidgetModel.

### Presentation

Содержит:

- экраны;
- виджеты;
- WidgetModel;
- Model;
- presentation strings.

Presentation не обращается напрямую к storage/API. Сценарий идёт через Model и domain/data зависимости, переданные через DI.

## 5. Паттерн экрана

Типовой экран:

```text
<screen>_screen.dart
<screen>_wm.dart
<screen>_model.dart
widgets/mobile/
widgets/desktop/
strings/
```

Правила:

- `screen` отвечает за маршрут и делегирование mobile/desktop версии;
- `wm` хранит UI-состояние и пользовательские действия;
- `model` вызывает use case и репозитории;
- крупная вёрстка живёт в `widgets/mobile` и `widgets/desktop`;
- изменяемое состояние в WM оформляется через `ValueNotifier`.

## 6. DI и AppScope

`AppScopeRegister` создаёт:

- конфигурацию;
- логгер;
- хранилища;
- auth backend;
- репозитории;
- sync queue;
- sync manager;
- use case;
- gateways;
- глобальные listenable-сервисы.

Фичи получают зависимости через `IAppScope` или локальные scope, если фиче нужен отдельный жизненный цикл.

## 7. Навигация

- Пути: `lib/app_routing/app_route_paths.dart`.
- Граф: `lib/features/navigation/app_router.dart`.
- Сгенерированные маршруты: `app_router.gr.dart`.

Для переходов использовать типизированные route-классы.

## 8. Данные

Основные сущности задач:

- `TaskEntity`;
- `TaskListEntity`;
- `TaskMaterialRequirementEntity`;
- `TaskImageAttachmentEntity`;
- сущности бюджета и склада для decision-системы.

Локальные данные хранятся в Hive. При изменениях, которые должны попасть в облако, repository сохраняет данные локально и ставит sync operation в очередь.

## 9. Синхронизация

Компоненты:

- `ISyncQueue`;
- `SyncQueueHiveStorage`;
- `SyncManagerImpl`;
- `ISyncRemoteExecutor`;
- backend-specific executor.

Синхронизация должна быть безопасной для offline-first сценария: локальные действия пользователя не зависят от текущей сети.

## 10. Локализация

Пользовательские строки в presentation не вызывают `FlutterI18n.translate` напрямую. Для каждой фичи используются классы `*Strings` в `presentation/strings`.

## 11. Чеклист новой фичи

1. Создать каталог `features/<name>`.
2. Разделить `domain`, `data`, `presentation`.
3. Завести entity и интерфейсы в domain.
4. Реализовать repository/gateway в data.
5. Собрать Screen + WM + Model.
6. Добавить route и сгенерировать `app_router.gr.dart`.
7. Добавить строки локализации.
8. Покрыть domain/use case тестами при наличии бизнес-логики.

## 12. Чеклист перед изменением

- Не смешаны ли слои?
- Нет ли прямых строковых маршрутов?
- Нет ли пользовательских строк вне локализации?
- Освобождаются ли `ValueNotifier` и подписки?
- Не теряется ли offline-first поведение?
- Не ставится ли лишняя sync operation при входящем merge?
