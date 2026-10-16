---
name: rooster-feature-delivery
description: Создание или расширение фичи Rooster по текущим образцам Elementary — Screen/WM/Model, DI, маршруты auto_route, адаптивный UI и JSON-переводы. Используй для реализации фич и экранов; для локального исправления выбирай более узкий навык.
---

# Реализация фичи Rooster

Все пути относительны корня репозитория. Реализуй пользовательский сценарий
в нужных слоях; не создавай пустые repositories, scopes и use cases ради шаблона.
Проверь актуальность образцов перед копированием.

## Найди подходящий образец

- Простой экран: три файла в
  `lib/features/settings/presentation/screens/settings/` —
  `settings_screen.dart`, `settings_wm.dart`, `settings_model.dart`.
- Экран с зависимостями: фабрика в
  `lib/features/auth/presentation/screens/auth/auth_screen.dart`.
- Domain/data: `lib/features/tasks/domain/repositories/i_tasks_repository.dart`
  и `lib/features/tasks/data/repositories/tasks_repository_impl.dart`.
- Реальные сигнатуры: `lib/core/architecture/presentation/base_widget.dart`
  и `lib/core/architecture/presentation/base_widget_model.dart`.

## Проведи сценарий через слои

1. Определи вход в сценарий, данные, изменение состояния и наблюдаемый итог.
   Найди существующие contracts/use cases для переиспользования. Добавляй
   domain entities и интерфейсы только при необходимости; сохраняй принятые
   типы возврата. DTO не должны становиться UI-моделью.
2. Создай `*_screen.dart`, `*_wm.dart`, `*_model.dart` в
   `lib/features/<feature>/presentation/screens/<screen>/`.
   Screen использует `BaseWidget<ConcreteWM>`, а WM —
   `BaseWidgetModel<Screen, Model>` по действующим образцам.
   Текущие build-методы принимают только WM: `buildMobile(Wm wm)` и
   `buildDesktop(Wm wm)`. Model наследует `ElementaryModel`.
3. Передавай зависимости в Model через конструктор. Фабрика WM получает
   `IAppScope` через `context.read<IAppScope>()` и SnackQueue через provider.
   Если нужна новая общая зависимость, согласованно обнови
   `lib/features/app/di/app_scope.dart` и
   `lib/features/app/di/app_scope_register.dart`, включая её жизненный цикл.
   Не вводи отдельный feature scope автоматически: большинство фич используют
   корневой scope. Проверь освобождение подписок и notifier в WM.
4. Оставь навигацию и обработку действий в WM, а данные View предоставляй
   через свойства WM. Для сложных состояний используй существующий UnionState
   API, для простых — подходящий ValueListenable. Не обращайся из View к
   внутреннему состоянию `wm.model`.
5. Реализуй мобильный и desktop-варианты через UIKit и действующие темы/размеры.
   Платформенные виджеты размещай по образцу `widgets/mobile/` и
   `widgets/desktop/`. Проверь loading/error/empty, если сценарий их имеет.

## Подключи маршруты и тексты

- Добавь `@RoutePage` к экрану. Если нужен вложенный стек, используй
  `lib/features/settings/presentation/settings_flow.dart` как образец flow.
- Импортируй экран и зарегистрируй route в
  `lib/features/navigation/app_router.dart`; проверь мобильный и desktop-графы.
  Явное имя `@RoutePage(name: ...)` важнее предположений о replaceInRouteName.
- Новые именованные URL-пути размещай в `lib/app_routing/app_route_paths.dart`.
  При добавлении пункта desktop-навигации проверь
  `lib/features/navigation/main_desktop_shell_navigation.dart` и
  `lib/features/app/presentation/widgets/main_desktop_navigation_sidebar.dart`.
- Строки добавляй в `assets/flutter_i18n/ru.json` и
  `assets/flutter_i18n/en.json` с одинаковыми ключами и параметрами.
  Используй `FlutterI18n.translate` или strings-класс по образцу
  `lib/features/settings/presentation/strings/settings_strings.dart`.
  ARB и генерация AppLocalizations для этого пути не нужны.

## Генерация и завершение

В `mason.yaml` зарегистрированы только `feature` и `screen`. Перед применением
bricks проверь их импорты, зависимости и сигнатуры: наличие шаблона не делает
его актуальнее работающего кода. Не используй отсутствующий brick `widget`.

После изменения routes/аннотаций выполни build_runner по
`../rooster-validation/SKILL.md`, проверь generated diff. Не правь `.gr.dart`,
`.g.dart` или `.freezed.dart` вручную и не запускай генерацию только из-за
обычной правки текста или UI.

Для новой операции хранения прочитай `../rooster-offline-sync/SKILL.md`;
для изменения входа — `../rooster-auth-debug/SKILL.md`. Выполни релевантные
domain/widget-тесты и проверь доступность экрана в обоих графах. Отчёт должен
показывать реализованный сценарий, результаты проверок и оставшиеся ограничения.
