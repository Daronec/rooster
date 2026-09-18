# Аудит кода по правилам .gigacode/skills

**Дата:** 2026-09-18  
**Проект:** client_velo_app (Flutter)  
**Источник правил:** `.gigacode/skills/`

---

## Сводная таблица

| Категория | Критичность | Нарушений | Файлов |
|-----------|------------|-----------|--------|
| `context.router` вместо `wm.router` | 🔴 Критическая | 35 | 16 |
| AI Chat не следует архитектуре MVVM | 🔴 Критическая | 1 | 1 |
| Hardcoded строки в UI | 🟡 Средняя | 29 | 13 |
| Bang operator (`!`) | 🟡 Средняя | 20 | 11 |
| Raw Flutter widgets вместо UI Kit | 🟡 Средняя | 8 | 5 |
| `Theme.of(context)` вместо `wm.colorScheme` | 🟡 Средняя | 3 | 3 |
| `EdgeInsets` вместо `AppSizes` | 🟢 Легкая | 15 | 9 |
| Относительные импорты | ✅ Чисто | 0 | — |
| Private classes в main файлах | ✅ Чисто | 0 | — |
| View → Model прямой доступ | ✅ Чисто | 0 | — |
| `Scaffold` вместо `AppScaffold` | ✅ Чисто | 0 | — |

---

## 🔴 КРИТИЧЕСКИЕ (архитектурные)

### 1. Навигация через `context.router` вместо `wm.router`

**Правило:** Навигация выполняется ТОЛЬКО через `wm.router`, никогда через `context.router`.

**Найдено:** 35 нарушений в 16 WM-файлах.

| Файл | Кол-во | Примеры |
|------|--------|---------|
| `create_task_wm.dart` | 7 | `context.router.push()`, `context.router.maybePop()` |
| `task_detail_wm.dart` | 5 | `context.router.push()`, `context.router.maybePop()` |
| `tasks_wm.dart` | 3 | `context.router.push(CreateTaskRoute())` |
| `profile_wm.dart` | 3 | `context.router.root.push()`, `context.router.replaceAll()` |
| `task_lists_wm.dart` | 2 | `context.router.push()` |
| `auth_wm.dart` | 2 | `context.router.push()`, `context.router.root.replaceAll()` |
| `create_task_list_wm.dart` | 3 | `context.router.maybePop()`, `context.router.push()` |
| `planning_wm.dart` | 3 | `context.router.push()` |
| `register_wm.dart` | 1 | `context.router.root.replaceAll()` |
| `settings_wm.dart` | 1 | `context.router.maybePop()` |
| `create_plan_wm.dart` | 1 | `context.router.pop()` |
| `create_plan_task_wm.dart` | 2 | `context.router.maybePop()` |
| `root_auth_gate_wm.dart` | 1 | `context.router.replaceAll()` |
| `task_change_history_wm.dart` | 1 | `context.router.maybePop()` |
| `decision_blocked_wm.dart` | 1 | `context.router.push()` |
| `decision_today_wm.dart` | 1 | `DecisionTaskNavigation.openTaskDetail(context, ...)` |

**Детали по файлам:**

#### `lib/features/tasks/presentation/screens/tasks/tasks_wm.dart`
- ~87: `context.router.push(CreateTaskRoute())`
- ~94: `context.router.push(CreateTaskRoute(taskId: taskId))`
- ~101: `context.router.push<void>(TaskDetailRoute(taskId: taskId))`

#### `lib/features/tasks/presentation/screens/task_detail/task_detail_wm.dart`
- ~87: `context.router.push<void>(CreateTaskRoute(taskId: model.taskId))`
- ~100: `context.router.push<void>(CreateTaskRoute(parentTaskId: model.taskId))`
- ~107: `context.router.push<void>(CreateTaskRoute(taskId: taskId))`
- ~114: `context.router.push<void>(TaskDetailRoute(taskId: taskId))`
- ~165: `context.router.maybePop()`

#### `lib/features/tasks/presentation/screens/create_task/create_task_wm.dart`
- ~145: `context.router.maybePop()`
- ~295: `context.router.maybePop()`
- ~302: `context.router.push<void>(CreateTaskRoute(parentTaskId: parentId))`
- ~318: `context.router.push<void>(CreateTaskRoute(taskId: taskId))`
- ~326: `context.router.push<void>(TaskChangeHistoryRoute(taskId: taskId))`
- ~380: `context.router.maybePop()`
- ~515: `context.router.maybePop(task)`

#### `lib/features/tasks/presentation/screens/task_lists/task_lists_wm.dart`
- ~33: `context.router.push<void>(CreateTaskListRoute())`
- ~38: `context.router.push<void>(CreateTaskListRoute(listId: listId))`

#### `lib/features/tasks/presentation/screens/create_task_list/create_task_list_wm.dart`
- ~50: `context.router.maybePop()`
- ~80: `context.router.maybePop()`
- ~87: `context.router.maybePop()`

#### `lib/features/auth/presentation/screens/auth/auth_wm.dart`
- ~118: `context.router.push<void>(const RegisterRoute())`
- ~156: `context.router.root.replaceAll(...)`

#### `lib/features/auth/presentation/screens/register/register_wm.dart`
- ~171: `context.router.root.replaceAll(...)`

#### `lib/features/profile/presentation/screens/profile/profile_wm.dart`
- ~200: `context.router.root.push<void>(const AuthFlowRoute())`
- ~207: `context.router.root.push<void>(const SettingsFlowRoute())`
- ~215: `context.router.replaceAll(rootMainAppStack(context))`

#### `lib/features/settings/presentation/screens/settings/settings_wm.dart`
- ~30: `context.router.maybePop()`

#### `lib/features/planning/presentation/screens/planning/planning_wm.dart`
- ~33: `context.router.push<void>(const CreatePlanRoute())`
- ~38: `context.router.push<TaskEntity?>(CreateTaskRoute())`
- ~68: `context.router.push<void>(TaskDetailRoute(taskId: task.id))`

#### `lib/features/planning/presentation/screens/create_plan/create_plan_wm.dart`
- ~118: `context.router.pop()`

#### `lib/features/planning/presentation/screens/create_plan_task/create_plan_task_wm.dart`
- ~85: `context.router.maybePop()`
- ~95: `context.router.maybePop()`

#### `lib/features/auth/presentation/root_auth_gate/root_auth_gate_wm.dart`
- ~28: `context.router.replaceAll(rootMainAppStack(context))`

#### `lib/features/tasks/presentation/screens/task_change_history/task_change_history_wm.dart`
- ~30: `context.router.maybePop()`

#### `lib/features/tasks/presentation/screens/decision/blocked/decision_blocked_wm.dart`
- ~30: `context.router.push<void>(CreateTaskRoute(...))`

#### `lib/features/tasks/presentation/screens/decision/today/decision_today_wm.dart`
- ~30: `DecisionTaskNavigation.openTaskDetail(context, taskId: task.id)` — helper сам вызывает `context.router.push()`

---

### 2. AI Chat screen не следует архитектуре Elementary MVVM

**Правило:** Каждый экран должен использовать `BaseWidget<W>` и WM-слой.

**Файл:** `lib/features/ai/presentation/screens/ai_chat/ai_chat_screen.dart`

| Проблема | Детали |
|----------|--------|
| Расширяет `StatefulWidget` | Вместо `BaseWidget<IAiChatWM>` |
| WM не используется | Файл `ai_chat_wm.dart` существует, но screen его не использует |
| Локальное состояние | `List<_Message> _messages`, `bool _isLoading` — должно быть в WM |
| Прямой доступ к DI | `context.read<IAppScope>().localLLMGateway` — должно быть в WM |

---

## 🟡 СРЕДНИЕ

### 3. Hardcoded строки в UI

**Правило:** Все тексты должны быть в локализации (`context.l10n.key` или `l10n.key`).

**Найдено:** 29 нарушений в 13 файлах.

#### `lib/features/ai/presentation/screens/ai_chat/ai_chat_screen.dart` — 8 нарушений

| Строка | Строка | Виджет |
|--------|--------|--------|
| 28 | `'AI Ассистент'` | AppBar title |
| 58 | `'AI Ассистент'` | Welcome heading |
| 64 | `'Задайте вопрос о ваших задачах,\nприоритетах или планах'` | Welcome body |
| 95 | `'Введите запрос...'` | TextField hint |
| 117 | `'LLM пока не доступна...'` | Error message |
| 126 | `'Произошла ошибка при генерации ответа.'` | Error message |
| 132 | `'Ошибка: $e'` | Error message |
| 137 | Prompt template (hardcoded Russian) | `_buildPrompt()` |

#### `lib/features/dev_panel/presentation/screens/dev_panel/widgets/desktop/dev_panel_desktop_content.dart` — 6 нарушений

| Строка | Строка | Виджет |
|--------|--------|--------|
| 29 | `'Dev / Sync'` | AppBar title |
| 47 | `'Статус: ${wm.syncStatus}'` | Status |
| 48 | `'Сеть (индикатор): ${wm.online.value ?? '...'}'` | Network |
| 54 | `'Пауза исходящего sync'` | SwitchListTile title |
| 55 | `'Очередь копится локально'` | SwitchListTile subtitle |
| 63 | `'Очередь:'` | Queue label |

#### `lib/features/dev_panel/presentation/screens/dev_panel/widgets/mobile/dev_panel_mobile_content.dart` — 6 нарушений

Те же строки, что и в desktop версии.

#### Loading/Failure виджеты — AppBar titles

| Файл | Строка | Виджет |
|------|--------|--------|
| `task_lists_desktop_failure.dart` | 32 | `Text('Списки')` |
| `task_lists_desktop_loading.dart` | 30 | `Text('Списки')` |
| `task_lists_mobile_failure.dart` | 32 | `Text('Списки')` |
| `task_lists_mobile_loading.dart` | 30 | `Text('Списки')` |
| `tasks_desktop_failure.dart` | 33 | `Text('Задачи')` |
| `tasks_desktop_loading.dart` | 31 | `Text('Задачи')` |
| `tasks_mobile_failure.dart` | 33 | `Text('Задачи')` |
| `tasks_mobile_loading.dart` | 31 | `Text('Задачи')` |
| `dev_panel_desktop_failure.dart` | — | `Text('Dev / Sync')` |
| `dev_panel_desktop_loading.dart` | — | `Text('Dev / Sync')` |
| `dev_panel_mobile_failure.dart` | — | `Text('Dev / Sync')` |
| `dev_panel_mobile_loading.dart` | — | `Text('Dev / Sync')` |

#### `lib/features/app/presentation/widgets/main_desktop_navigation_sidebar.dart` — 1 нарушение

| Строка | Строка | Виджет |
|--------|--------|--------|
| 103 | `'Rooster'` | Sidebar header |

---

### 4. Bang operator (`!`)

**Правило:** Никогда не использовать `!`, всегда предоставлять default values.

**Найдено:** 20 нарушений в 11 файлах.

#### `lib/features/tasks/domain/services/task_creation_input_from_task_entity.dart` — 4

| Строка | Код |
|--------|-----|
| 25 | `endAt!.subtract(Duration(minutes: duration))` |
| 30 | `entity.dueAt!.year,` |
| 31 | `entity.dueAt!.month,` |
| 32 | `entity.dueAt!.day,` |

#### `lib/features/ai/data/local_llm_gateway_impl.dart` — 3

| Строка | Код |
|--------|-----|
| 57 | `await _bindings!.generate(` |
| 71 | `_handle!,` |
| 95 | `_bindings?.dispose(_handle!);` |

#### `lib/features/ai/domain/use_cases/categorize_task_use_case.dart` — 1

| Строка | Код |
|--------|-----|
| 14 | `if (llmGateway == null \|\| !llmGateway!.isInitialized) {` |

#### `lib/features/ai/domain/use_cases/classify_task_priority_use_case.dart` — 1

| Строка | Код |
|--------|-----|
| 14 | `if (llmGateway == null \|\| !llmGateway!.isInitialized) {` |

#### `lib/features/tasks/data/repositories/task_image_upload_enqueue_io.dart` — 1

| Строка | Код |
|--------|-----|
| 22 | `if (image.remoteUrl != null && image.remoteUrl!.isNotEmpty) {` |

#### `lib/features/tasks/domain/decision/calculate_task_feasibility.dart` — 2

| Строка | Код |
|--------|-----|
| 97 | `(row.stockItemId != null && row.stockItemId!.trim().isNotEmpty)` |
| 98 | `? row.stockItemId!.trim()` |

#### `lib/features/tasks/presentation/screens/create_task/create_task_form_state.dart` — 3

| Строка | Код |
|--------|-----|
| 425 | `input.dueDateOnly!.year,` |
| 426 | `input.dueDateOnly!.month,` |
| 427 | `input.dueDateOnly!.day,` |

#### `lib/features/tasks/presentation/screens/create_task/create_task_wm.dart` — 3

| Строка | Код |
|--------|-----|
| 421 | `if (_formState.parentTaskId == null \|\| _formState.parentTaskId!.isEmpty) {` |
| 430 | `final parent = await model.loadTask(_formState.parentTaskId!);` |
| 431 | `if (_formState.selectedListId == null \|\| _formState.selectedListId!.isEmpty) {` |

#### `lib/features/tasks/presentation/screens/decision/today/widgets/decision_today_body.dart` — 1

| Строка | Код |
|--------|-----|
| 130 | `: MaterialLocalizations.of(context).formatShortDate(task.dueAt!.toLocal());` |

#### `lib/features/tasks/presentation/screens/tasks/tasks_model.dart` — 1

| Строка | Код |
|--------|-----|
| 112 | `.where((task) => task.parentTaskId == null \|\| task.parentTaskId!.isEmpty)` |

#### `lib/integration/appwrite/appwrite_task_sync_executor.dart` — 4

| Строка | Код |
|--------|-----|
| 183 | `if (task.executorUserId != null && task.executorUserId!.trim().isNotEmpty)` |
| 184 | `task.executorUserId!.trim(),` |
| 185 | `if (task.observerUserId != null && task.observerUserId!.trim().isNotEmpty)` |
| 186 | `task.observerUserId!.trim(),` |

#### `lib/features/tasks/presentation/screens/task_detail/widgets/task_detail_scroll_view.dart` — 1

| Строка | Код |
|--------|-----|
| 264 | `task.customReminderAt!,` |

#### `lib/uikit/buttons/app_base_button.dart` — 1

| Строка | Код |
|--------|-----|
| 96 | `child: widget.subtitle!,` |

---

### 5. Raw Flutter widgets вместо UI Kit

**Правило:** Использовать `AppPrimaryButton`, `AppBlackButton`, `AppGrayButton` вместо raw кнопок.

**Найдено:** 8 нарушений.

| Файл | Строка | Виджет | Контекст |
|------|--------|--------|----------|
| `tasks_wm.dart` | 147 | `TextButton` | AlertDialog actions (удаление) |
| `create_task_wm.dart` | 739 | `OutlinedButton` | showModalBottomSheet (выбор родительской задачи) |
| `create_task_wm.dart` | 856 | `TextButton` | AlertDialog actions (удаление задачи) |
| `create_task_wm.dart` | 895 | `TextButton` | AlertDialog actions (удаление подзадачи) |
| `task_detail_scroll_view.dart` | 107 | `TextButton.icon` | Кнопка добавления подзадачи |
| `profile_wm.dart` | 156 | `TextButton` | AlertDialog actions (редактирование имён) |
| `profile_wm.dart` | 346 | `TextButton` | AlertDialog actions (создание команды) |
| `profile_wm.dart` | 486 | `TextButton` | AlertDialog actions (приглашение в команду) |

---

### 6. `Theme.of(context)` вместо `wm.colorScheme` / `wm.textScheme`

**Правило:** Использовать тему из wm, не `Theme.of(context)`.

**Найдено:** 3 нарушения.

| Файл | Строка | Код |
|------|--------|-----|
| `tasks_desktop_failure.dart` | 45 | `Theme.of(context).textTheme.bodySmall` |
| `task_list_item.dart` | 40 | `Theme.of(context).colorScheme` |
| `create_task_wm.dart` | 719 | `Theme.of(sheetContext).textTheme.titleMedium` |

---

## 🟢 ЛЕГКИЕ

### 7. `EdgeInsets` вместо `AppSizes`

**Правило:** Использовать `AppSizes.edgeInsetsAll16`, `AppSizes.edgeInsetsSymmetricH12V16` и т.д.

**Найдено:** 15 нарушений в 9 файлах.

| Файл | Строка | Код |
|------|--------|-----|
| `decision_today_body.dart` | 39 | `EdgeInsets.all(AppSizes.double24)` |
| `decision_resources_body.dart` | 39 | `EdgeInsets.all(AppSizes.double24)` |
| `decision_blocked_body.dart` | 39 | `EdgeInsets.all(AppSizes.double24)` |
| `decision_blocked_body.dart` | 131 | `EdgeInsets.only(bottom: AppSizes.double16)` |
| `decision_blocked_body.dart` | 185 | `EdgeInsets.only(bottom: AppSizes.double8)` |
| `planning_desktop_content.dart` | 31 | `EdgeInsets.all(AppSizes.double24)` |
| `task_detail_scroll_view.dart` | 112 | `EdgeInsets.only(bottom: AppSizes.double8)` |
| `task_detail_scroll_view.dart` | 140 | `EdgeInsets.only(bottom: AppSizes.double8)` |
| `task_detail_scroll_view.dart` | 234 | `EdgeInsets.only(bottom: AppSizes.double12)` |
| `tasks_grouped_list_group_tile.dart` | 38 | `EdgeInsets.only(bottom: AppSizes.double8)` |
| `decision_resources_editor.dart` | 118 | `EdgeInsets.all(AppSizes.double12)` |
| `decision_resources_editor.dart` | 133 | `EdgeInsets.only(bottom: AppSizes.double8)` |
| `create_task_wm.dart` | 712 | `EdgeInsets.all(AppSizes.double16)` |
| `tasks_grouped_list_task_sections.dart` | 80 | `EdgeInsets.only(bottom: AppSizes.double8, left: AppSizes.double16)` |
| `create_task_form_scaffold.dart` | 162 | `const EdgeInsets.all(AppSizes.double12)` |

---

## ✅ ЧИСТО (нарушений не найдено)

| Проверка | Статус |
|----------|--------|
| Относительные импорты (`'../`) | ✅ 0 нарушений |
| Private classes в main файлах | ✅ 0 нарушений |
| View → Model прямой доступ | ✅ 0 нарушений |
| `Scaffold` вместо `AppScaffold` | ✅ 0 нарушений |

---

## Рекомендации по приоритетам исправления

### Приоритет 1 — Критические
1. Рефакторинг навигации в 16 WM-файлах: внедрить `AppRouter` через конструктор вместо `context.router`
2. Переписать `ai_chat_screen.dart` на архитектуру `BaseWidget<IAiChatWM>`

### Приоритет 2 — Средние
3. Вынести все hardcoded строки в локализацию (29 строк)
4. Заменить `!` на `??` / `?.` / early return (20 случаев)
5. Заменить raw кнопки на UI Kit (8 случаев)
6. Заменить `Theme.of(context)` на `wm.colorScheme` (3 случая)

### Приоритет 3 — Легкие
7. Заменить `EdgeInsets` на `AppSizes` константы (15 случаев)
