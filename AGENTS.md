# Инструкции Codex для Rooster

## Локальные навыки

Используй `.gigacode/skills/` как источник проектных навыков. Пути ниже
относительны корня репозитория. Перед работой прочитай подходящие к задаче
файлы целиком и следуй применимым инструкциям. Не загружай весь каталог для
каждой задачи. При явном упоминании навыка прочитай соответствующий `SKILL.md`.
Это подключение через инструкции проекта; оно не регистрирует навыки в
глобальном каталоге или меню навыков Codex.

Перед изменением кода прочитай:

- `.gigacode/skills/architecture/SKILL.md`
- `.gigacode/skills/code-style/SKILL.md`
- `.gigacode/skills/commands/SKILL.md`
- `.gigacode/skills/only-in-context/SKILL.md`

Остальные навыки выбирай по области задачи:

| Навык | Когда читать | Файл |
| --- | --- | --- |
| analytics | Логирование, аналитика, уведомления SnackQueue | `.gigacode/skills/analytics/SKILL.md` |
| animations | Анимации, переходы, доступность движения | `.gigacode/skills/animations/SKILL.md` |
| api | DTO, Retrofit, API-сервисы и адреса | `.gigacode/skills/api/SKILL.md` |
| codegen | Генерация кода, аннотации, шаблоны Mason | `.gigacode/skills/codegen/SKILL.md` |
| data | Реализации репозиториев и преобразование данных | `.gigacode/skills/data/SKILL.md` |
| di | Внедрение зависимостей, scope и освобождение ресурсов | `.gigacode/skills/di/SKILL.md` |
| domain | Сущности, бизнес-логика и интерфейсы репозиториев | `.gigacode/skills/domain/SKILL.md` |
| error-handling | Ошибки, состояния загрузки, повторные попытки | `.gigacode/skills/error-handling/SKILL.md` |
| localization | Переводы, пользовательские строки, множественные формы | `.gigacode/skills/localization/SKILL.md` |
| navigation | Маршруты, параметры переходов, платформенная навигация | `.gigacode/skills/navigation/SKILL.md` |
| persistence | Локальное хранение, кеширование, защищённое хранилище | `.gigacode/skills/persistence/SKILL.md` |
| presentation | Screen, WidgetModel, Model и UI-состояние | `.gigacode/skills/presentation/SKILL.md` |
| testing | Unit-, widget- и golden-тесты | `.gigacode/skills/testing/SKILL.md` |
| uikit | Компоненты интерфейса, тема, размеры и адаптивная вёрстка | `.gigacode/skills/uikit/SKILL.md` |
| utilities | Расширения, форматтеры, константы и утилиты | `.gigacode/skills/utilities/SKILL.md` |
| rule-check | Проверка или восстановление контекста правил | `.gigacode/skills/rule-check/SKILL.md` |
| update-memory | Обработка `cursor_rules_context` или запрос обновить правила | `.gigacode/skills/update-memory/SKILL.md` |
| flutter-fix-layout-issues | Overflow, неограниченные размеры, вёрстка при открытии клавиатуры | `.gigacode/skills/flutter-fix-layout-issues/SKILL.md` |
| flutter-add-widget-test | Проверка отображения экранов и взаимодействий через WidgetTester | `.gigacode/skills/flutter-add-widget-test/SKILL.md` |
| flutter-add-integration-test | Сквозные сценарии создания, изменения и восстановления задач | `.gigacode/skills/flutter-add-integration-test/SKILL.md` |
| dart-fix-runtime-errors | Исключения работающего приложения, stack trace и связанные ошибки типов | `.gigacode/skills/dart-fix-runtime-errors/SKILL.md` |
| dart-resolve-package-conflicts | Ошибки разрешения зависимостей pub и совместимость версий | `.gigacode/skills/dart-resolve-package-conflicts/SKILL.md` |
| dart-use-ffigen | Генерация FFI-привязок для нативных библиотек и локального LLM | `.gigacode/skills/dart-use-ffigen/SKILL.md` |
| rooster-offline-sync | Hive, очередь, повторная доставка, конфликты и восстановление после перезапуска | `.gigacode/skills/rooster-offline-sync/SKILL.md` |
| rooster-auth-debug | Активный OAuth/backend, callback, отмена входа, выход и восстановление сессии | `.gigacode/skills/rooster-auth-debug/SKILL.md` |
| rooster-feature-delivery | Реализация фичи по образцам Rooster, три файла экрана, DI, маршруты и JSON-переводы | `.gigacode/skills/rooster-feature-delivery/SKILL.md` |
| rooster-validation | Реальные команды форматирования, анализа, тестов и генерации | `.gigacode/skills/rooster-validation/SKILL.md` |

Навыки `rooster-*` уточняют общие навыки для текущего проекта и имеют
приоритет при расхождении с их примерами. Для проверок и генерации используй
`rooster-validation`: он разрешает прямые команды SDK вместо отсутствующих
make-целей; добавлять Makefile-обёртку ради каждой проверки не требуется.
Состояние backend и команды в навыках проверяй по текущему коду перед работой.

Дополнительные справочники:

- `.gigacode/skills/architecture.md` — подробная архитектура Rooster;
  читай при работе со слоями, DI, синхронизацией и новыми фичами.
- `.gigacode/skills/code_style.md` — дополнительные соглашения о стиле;
  читай при создании и рефакторинге классов и экранов.
- `.gigacode/skills/patterns.md` — рецепты экранов, API, DI и offline-first;
  читай для соответствующих сценариев, проверяя примеры по текущему коду.

## Применение к текущему проекту

В исходных навыках есть устаревшие примеры и фрагменты других проектов.
При расхождениях проверяй текущие объявления типов, соседний код,
`pubspec.yaml`, `analysis_options.yaml`, `Makefile` и существующие скрипты.
Не меняй архитектуру или зависимости только ради соответствия примеру.
Явные инструкции пользователя имеют приоритет над этими справочниками.

- Для импортов используй имя пакета из `pubspec.yaml` (`rooster`),
  а не `ekf_sales` или `client_velo_app` из примеров.
- В проекте используется `flutter_i18n` с
  `assets/flutter_i18n/ru.json` и `assets/flutter_i18n/en.json`.
  Не вводи ARB/AppLocalizations на основании старого примера.
- Сохраняй существующие контракты репозиториев: `Future`/`Stream`
  или `Result`, если конкретный интерфейс уже его использует.
  Не навязывай единый тип возврата всему проекту по одному навыку.
- Сигнатуры `BaseWidget`/`BaseWidgetModel`, навигацию, пороги адаптивности,
  методы логирования и SnackQueue сверяй с их реализациями.
- Предпочитай существующие команды Makefile и скрипты. Упомянутые в навыках
  `make codegen`, `make surfgen`, `make format`, `make intl_with_format`
  отсутствуют в текущем Makefile: не считай их доступными без проверки.
- Проверяй наличие тестовых библиотек, конфигураций и шаблонов перед
  использованием; перечисление в навыке не означает, что они установлены.
- Не редактируй сгенерированные файлы вручную. Выполняй подходящие проверки
  для изменённого кода и сообщай о проверках, которые не удалось выполнить.
- Служебные правила памяти применяй к реально прочитанным инструкциям;
  не заявляй о загрузке файлов или сохранении глобальной памяти без проверки.

## Уточнения для навыков Flutter и Dart

Шесть навыков выше с префиксами `flutter-` и `dart-` скопированы из
`flutter/agent-plugins` и `dart-lang/skills`. В каждой папке сохранены
`SOURCE.md` и `LICENSE`. Это навыки, а не конфигурации отдельных субагентов.
Их `metadata.model` — метаданные источника, а не указание менять модель Codex.
Следующие уточнения имеют приоритет над общими примерами этих навыков:

- Используй только фактически доступные MCP-инструменты. Если MCP или
  debug-сессия недоступны, используй доступные логи, анализатор и тесты;
  явно укажи, что проверка в работающем приложении не выполнена.
- Для layout-ошибок сначала проверь ограничения родителей. Не добавляй
  `Expanded` внутри неограниченного scrollable-контейнера вслепую.
  Проверяй мобильную и desktop-вёрстку, клавиатуру и масштаб текста.
- Для widget-тестов используй существующую инфраструктуру Rooster, DI,
  тему и JSON-локализацию. Не заменяй Elementary архитектурой из примера.
  Не используй бесконечный `pumpAndSettle` при постоянных анимациях.
- Для integration-тестов проверяй существующий bootstrap приложения.
  Flutter Driver extension, если он нужен выбранному инструменту,
  включай только в отдельной тестовой точке входа с нужной dev-зависимостью.
  Для сценария «создать → изменить → перезапустить → проверить» проверяй
  восстановление из хранилища после остановки и нового запуска процесса;
  hot reload или повторный `pumpWidget` не доказывают сохранность данных.
- `dart-fix-runtime-errors` в текущем источнике в основном описывает
  статический анализ. Для runtime-задач сначала получи исключение и stack
  trace, воспроизведи сбой, исправь причину и повтори исходный сценарий.
  Не меняй глобальные lint-правила и не запускай массовый `dart fix --apply`
  ради локальной ошибки. Для Flutter-тестов используй `flutter test`.
- При конфликтах зависимостей читай вывод solver и ограничения SDK.
  Сохраняй намеренно закреплённые версии и предпочитай целевые команды pub
  ручному редактированию `pubspec.lock`. Не обновляй все зависимости
  и не удаляй lockfile как стандартный способ устранения конфликта.
- Для FFI сначала проверь установленную версию `ffigen`, существующий
  генератор, заголовки и ABI целевых платформ. Сохраняй принятую структуру
  проекта; обновляй генератор, а не сгенерированные привязки вручную.
