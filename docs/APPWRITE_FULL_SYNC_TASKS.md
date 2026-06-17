# Полная синхронизация задач и списков с Appwrite

Документ фиксирует перечень работ для синхронизации локального хранилища (Hive, offline-first) с Appwrite: при отсутствии интернета изменения сохраняются локально и попадают в очередь; при появлении сети выполняется отправка и (после реализации входящего потока) подтягивание данных из облака.

Архитектурная опора в коде: `ISyncQueue`, `SyncManagerImpl`, `ISyncRemoteExecutor`, `SyncOperationType`, кодеки `TaskEntityCodec` / `TaskListEntityCodec`, эталон исходящей синхронизации — `SupabaseTaskSyncExecutor`.

---

## A. Appwrite (консоль и инфраструктура)

1. **Коллекция задач** (`user_tasks` или согласованное имя): атрибуты для хранения полного снимка — `userId`, `taskId` (строка = локальный UUID), `document` (объект или JSON-строка со всем содержимым, эквивалентным `TaskEntityCodec.toMap`: `schemaVersion`, `id`, `listId`, `parentTaskId`, `isPinned`, `importance`, `complexity`, `estimatedCost`, `materialRequirements`, `dependencyTaskIds`, `title`, `description`, даты (`dueAt`, `startAt`, `endAt`), `isAllDay`, `durationMinutes`, напоминания (`reminderOffsetMinutes`, `reminderPreset`, `customReminderAt`), `priority`, `tags`, рекуррентность (`recurrenceWeekdaysMask`, `recurrenceReminderMinutesFromMidnight`), `imageAttachments`, `status`, `contentRevision`, `updatedAtMillis`, `syncState`).
2. **Коллекция списков** (`user_task_lists`): `userId`, `listId`, полный `document` из `TaskListEntityCodec.toMap` (`id`, `name`, `colorArgb`, `contentRevision`, `updatedAtMillis`).
3. **Индексы** под выборку всех документов пользователя и при необходимости по `updatedAtMillis` / `taskId`.
4. **Права доступа** (только владелец: `userId` соответствует текущему аккаунту Appwrite), политики create / read / update / delete.
5. **Storage**: отдельный bucket для файлов изображений задач; лимиты размера и MIME; политики доступа согласованы с доступом к задачам.
6. **Стратегия идентификатора документа**: зафиксировать — `$id` документа в Appwrite равен `taskId` / `listId` **или** отдельный внутренний id с уникальным индексом по паре `(userId, taskId)`.

---

## B. Исходящая синхронизация (очередь → Appwrite)

7. Реализовать **`AppwriteTaskSyncExecutor`** (`ISyncRemoteExecutor`): обработка всех значений `SyncOperationType` — `upsertTask`, `deleteTask`, `upsertTaskList`, `deleteTaskList`, `uploadTaskImage`, `patchTaskStatus` (по аналогии с `SupabaseTaskSyncExecutor`, без потери полей сущности).
8. Подключить **один экземпляр `Client`** Appwrite с активной сессией для `Databases` и `Storage` (тот же клиентский контур, что и для Auth).
9. В **`AppwriteAuthBackendAssemblyStrategy`** подставить `AppwriteTaskSyncExecutor` вместо `LocalOnlySyncExecutor` при валидной конфигурации и сессии; при отсутствии сессии возвращать сбой с **`SyncAuthRequiredException`** (как в Supabase-ветке).
10. **Логирование** всех обращений к Appwrite: тип операции, идентификатор сущности, успех или код ошибки; детальные ветки — только в режиме отладки (`kDebugMode`).
11. Убедиться, что при сетевых сбоях операция **остаётся в очереди**, увеличивается `attemptCount`, применяется backoff через существующий `SyncManagerImpl`.
12. После успешной **авторизации** инициировать синхронизацию (`syncManager.requestSync()`), при необходимости — повторно после восстановления сессии из хранилища.

---

## C. Изображения и полнота полей задачи

13. **`uploadTaskImage`**: загрузка файла в Storage, получение стабильного идентификатора или URL, обновление локальной задачи (`remoteUrl` во вложениях), согласованная постановка `upsertTask` в очередь (как принято для Supabase в проекте).
14. Проверить укладку **всего** тела `document` в лимиты Appwrite; при риске превышения — не дублировать бинарные данные в документе, хранить в Storage только ссылки.
15. Сохранять в облаке **целиком** `materialRequirements` (включая `id`, `stockItemId` и пр.) и **`dependencyTaskIds`** без обрезки полей.

---

## D. Входящая синхронизация (Appwrite → Hive)

16. Сервис или use case **начальной выгрузки** после входа: список документов по `userId`, с пагинацией.
17. **Маппинг** ответа API Appwrite → DTO → восстановление сущности через `TaskEntityCodec.fromMap` / `TaskListEntityCodec.fromMap` (или отдельный конвертер, если обёртка документа отличается от карты Hive).
18. **Слияние с локальными данными**: явная политика по `updatedAtMillis` и/или `contentRevision` (побеждает более новая версия; зафиксировать поведение при равенстве).
19. Запись в репозитории **без лишнего дублирования исходящих операций** (импорт «из облака» или сравнение ревизий до постановки в очередь).
20. Опционально: **Realtime** подписка на коллекции задач и списков с тем же алгоритмом merge.
21. Согласовать обновление **`TaskSyncStateEntity`** и отображение состояния синхронизации в UI после успешного upsert и после pull.

---

## E. Офлайн и жизненный цикл

22. Зафиксировать и при необходимости доработать сценарии: **офлайн** — репозитории пишут в Hive и ставят операции в `sync_queue`; при **появлении сети** — `ConnectivityGateway` и `requestSync()` обрабатывают очередь; при отсутствии сессии — корректная пауза без бесконечных бесполезных ретраев (см. `SyncAuthRequiredException`).
23. После длительного офлайна при возврате онлайн выполнять **pull** с сервера, а не только слив исходящей очереди (чтобы получить изменения с других устройств).
24. **Смена пользователя**: очистка или перезагрузка локальных данных и полный resync под новый `userId`.

---

## F. Тесты и приёмка

25. Юнит-тесты: маппинг entity ↔ документ Appwrite; `execute` для каждого `SyncOperationType` с моками клиента.
26. Ручные / интеграционные сценарии: офлайн → несколько правок → онлайн → проверка документов в консоли Appwrite; два устройства; конфликт одной задачи; удаление списка и связанных задач (порядок операций в очереди).
27. Регрессия: ветка без настроенного Appwrite (локальная только авторизация) не ломается.

---

## Критерий «все свойства задачи»

В облаке хранится полный снимок, эквивалентный **`TaskEntityCodec.toMap`** / **`TaskListEntityCodec.toMap`**. Локальные пути к файлам (`localPath`) не являются источником истины для других устройств; для изображений после загрузки использовать Storage и **`remoteUrl`**.
