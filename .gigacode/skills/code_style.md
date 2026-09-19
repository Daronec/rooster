# Code Style & Conventions

## Naming Conventions
- **Classes**: `PascalCase` (e.g., `BaseWidget`, `LoginWM`, `AppColorScheme`)
- **Interfaces**: `I` prefix (e.g., `IAuthRepository`, `IBaseWidgetModel`, `IAppScope`)
- **Private fields**: `_` prefix (e.g., `_isLoading`, `_profile`, `_authStateController`)
- **Static constants**: `k` prefix for domain constants (e.g., `_kAuthPrefix`)
- **Typedefs**: `PascalCase` (e.g., `RequestOperation`, `UnionStateListenable`)
- **File names**: `snake_case` (e.g., `base_widget_model.dart`, `app_scope.dart`)
- **Variables/Methods**: `camelCase` (e.g., `pushToRegistrationScreen`, `makeCall`)

## Import Style
- Flutter SDK imports first
- Third-party packages second
- Internal imports (`package:client_velo_app/...`) last
- **No relative imports** within the project — always use `package:` prefix
- **После создания/изменения класса — проверить все необходимые импорты**

### Правило: Проверка импортов для каждого класса

**Перед созданием или изменением класса обязательно проверить:**

1. **Все используемые типы импортированы** — включая:
   - Базовые классы/интерфейсы (e.g., `BaseWidget`, `BaseWidgetModel`, `BaseRepository`)
   - Сущности домена (e.g., `UserProfileEntity`, `TrainingSessionEntity`)
   - Интерфейсы репозиториев (e.g., `IProfileRepository`, `ITrainingRepository`)
   - DI-скупы (e.g., `IAppScope`, `IProfileScope`, `ITrainingScope`)
   - Entity из других фич (e.g., `TrainingDiscipline`, `TrainingLoadType` из `profile`)
   - Dart core типы (e.g., `Set`, `List`, `DateTime` — хотя они обычно не требуют импорта)

2. **AutoRoute-генерация** — проверить что:
   - `@RoutePage()` стоит на Screen-классе, а не на Flow-контейнере
   - Flow-контейнеры используют `@RoutePage(name: 'XFlowRoute')` на отдельном Screen-классе
   - Все Screen-классы имеют соответствующие `*_wm.dart` и `*_model.dart` файлы
   - Импорт Screen-класса есть в `app_router.dart`

3. **Freezed-сущности** — проверить что:
   - Есть именованный конструктор `ClassName._()` если есть getters
   - `part 'entity.freezed.dart'` и `part 'entity.g.dart'` присутствуют
   - `freezed_annotation` импортирован

4. **После создания файла — запустить build_runner** для генерации `.freezed.dart`, `.g.dart`, `.gr.dart`

Пример правильных импортов:
```dart
import 'package:auto_route/auto_route.dart';
import 'package:client_velo_app/core/architecture/presentation/base_widget.dart';
import 'package:client_velo_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:client_velo_app/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:client_velo_app/features/training/domain/entities/training_session_entity.dart';
import 'package:client_velo_app/features/training/domain/repositories/i_training_repository.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
```

## Formatting
- `dart format` with width=80 (as noted in generated files)
- Follow standard Dart formatting conventions

## Code Generation
The project uses multiple code generators — **never manually edit generated files**:
- `*.freezed.dart` — from `freezed` (immutable data classes)
- `*.g.dart` — from `json_serializable` (JSON serialization)
- `*.gr.dart` — from `auto_route` (navigation)
- `*.tailor.dart` — from `theme_tailor` (theme extensions)

Run `flutter pub run build_runner build` after modifying annotated files.

## Error Handling
- **Result Monad**: Use `Result<T, F>` sealed class (`ResultOk` / `ResultFailed`)
- **Failure Types**: Custom Failure subclasses (TimeoutFailure, NoInternetFailure, ApiFailure)
- **Repository Layer**: `BaseRepository.makeCall<T, E>` maps DioException → Failure
- **Screen Layer**: Handle Result in WM, display via SnackQueue

```dart
final result = await repository.fetchData();
result.when(
  ok: (data) => _handleSuccess(data),
  failed: (failure) => _handleFailure(failure),
);
```

## Reactive Patterns
- **ValueNotifier**: For simple boolean/state flags (e.g., `_isLoading`)
- **ValueListenable**: For repository state (e.g., `_profile.value`)
- **Streams (RxDart)**: For auth state, connectivity, sync queue changes
  ```dart
  final _authStateController = BehaviorSubject<AuthState>();
  Stream<AuthState> get authStateChanges => _authStateController.stream;
  ```
- **UnionState**: For screen phases (loading/content/failure)
  ```dart
  typedef UnionStateListenable<T> = ValueListenable<UnionState<T>>;
  ```

## Responsive Design
Every screen implements both `buildMobile()` and `buildDesktop()`:
```dart
@override
Widget buildMobile(ILoginWM wm) {
  return Column( /* mobile layout */ );
}

@override
Widget buildDesktop(ILoginWM wm) => buildMobile(wm); // or custom desktop layout
```

## Layer Separation — View Must Not Access Model Directly

**View (Screen) НЕ должен обращаться к `model.isLoading`, `model.someData.value` и т.д.**

Слои должны быть строго разделены:
- **Model** — хранит данные и состояние
- **WM (WidgetModel)** — преобразует данные модели, управляет логикой
- **View (Screen)** — только рендерит, получает данные через `wm.property`

```dart
// ❌ BAD — View обращается к model напрямую
ValueListenableBuilder<bool>(
  valueListenable: wm.model.isLoading,
  builder: (context, isLoading, _) {
    if (isLoading) return LoadingIndicator();
    return Content();
  },
)

// ❌ BAD — View обращается к model.data.value
text: wm.model.profile.value?.name

// ✅ GOOD — WM предоставляет готовое свойство для View
// В WM:
ValueListenable<bool> get showLoading => _showLoading;
ValueListenable<UserProfile?> get profileData => _profileData;

// В View:
ValueListenableBuilder<bool>(
  valueListenable: wm.showLoading,
  builder: (context, isLoading, _) { ... }
)

// ✅ GOOD — WM преобразует данные модели
ValueListenable<String?> get profileName => _profileName;

// В View:
text: wm.profileName.value
```

**Правила:**
1. View не вызывает `.value` на `wm.model.*`
2. View не использует `ValueListenableBuilder` с `wm.model.*`
3. WM предоставляет преобразованные данные через свои `ValueNotifier`/`ValueListenable`
4. WM управляет состоянием загрузки, а не View

## Navigation — роуты ТОЛЬКО через wm
**Навигация выполняется ТОЛЬКО через `wm.router`**, ни в коем случае не через `context.router`:

```dart
// ✅ GOOD — в WM
void goToNextScreen() {
  wm.router.push(SomeRoute());
}

// ✅ GOOD — в View через callback
IconButton(
  icon: const Icon(Icons.person_outline),
  onPressed: () => wm.router.push(const ProfileFlowRoute()),
)

// ❌ BAD — в View через context.router
IconButton(
  icon: const Icon(Icons.person_outline),
  onPressed: () => context.router.push(const ProfileFlowRoute()),
)

// ❌ BAD — в WM через router
void goToNext() {
  router.push(SomeRoute()); // undefined
}
```

## No Private Classes in Main Files
**Не создавать приватные классы (`_ClassName`) в файлах с основными классами.**
Создавайте отдельные файлы для вспомогательных классов:
```dart
// ❌ BAD — приватный класс в том же файле
class MyScreen extends StatelessWidget {
  // ...
}

class _MyTile extends StatelessWidget { // ❌
  // ...
}

// ✅ GOOD — приватный класс в отдельном файле
// my_screen.dart — только MyScreen
// my_tile.dart — класс _MyTile (или MyTile если публичный)
```

## Text Localization
**Все тексты выносить в локализацию**, никаких hardcoded строк в UI:
```dart
// ❌ BAD
Text('Hello World')

// ✅ GOOD — через AppLocalizations
Text(AppLocalizations.of(context).helloWorld)

// ✅ GOOD — через wm.model.strings (если screen-specific)
Text(wm.model.strings.helloWorld)
```

## Spacing with AppSizes
**Вместо хардкода размеров использовать `AppSizes` и виджеты `Height`/`Width`:**
```dart
// ❌ BAD
const SizedBox(height: 16)
const SizedBox(width: 8)

// ✅ GOOD
const Height(AppSizes.double16)
const Width(AppSizes.double8)

// Все размеры из AppSizes:
// AppSizes.double8, AppSizes.double16, AppSizes.double24, AppSizes.double32
```

## Theme-Aware Colors & Text
**Использовать тему из wm, а не Theme.of(context):**
```dart
// ✅ GOOD — в View через wm
Widget build(BuildContext context) {
  final colorScheme = wm.colorScheme;
  final textScheme = wm.textScheme;
  
  return Text('Hello', style: textScheme.bodyMedium);
}

// ❌ BAD — хардкод цветов
Container(color: Colors.blue)
Text('Hello', style: TextStyle(color: Colors.red))
```

## Padding with AppSizes
**Вместо хардкода padding использовать `AppSizes.edgeInsetsAll16`:**
```dart
// ❌ BAD
padding: const EdgeInsets.all(16)
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// ✅ GOOD
padding: AppSizes.edgeInsetsAll16
padding: AppSizes.edgeInsetsH16V8
```

## UI Kit Usage
Always use `lib/uikit/` components instead of raw Flutter widgets:
- **Buttons**: `AppPrimaryButton`, `AppBlackButton`, `AppGrayButton`
- **Scaffold**: `AppScaffold` instead of `Scaffold`
- **Fields**: `AppTextField` with built-in validators
- **Layout**: `Height()`, `Width()`, `EdgeInsets` из AppSizes
- **Spacing**: `AppSizes.edgeInsetsAll16` вместо `EdgeInsets.all(16)`

## Snack Queue (Notifications)
Centralized snack bar management:
```dart
// Get controller
final snackController = SnackQueueProvider.of(context);

// Show message
snackController.show('Message text');
```

## Persistence
- **Hive**: For structured data (profiles, sync queue, settings)
- **FlutterSecureStorage**: For tokens and sensitive data
- **SharedPreferences**: For simple key-value pairs

## Logging
Use `surf_logger` via `ILogWriter`:
```dart
final logger = scope.logger;
logger.i('Login successful');
logger.e('Login failed', error: exception, trace: stackTrace);
```

## Async Patterns
- Use `unawaited()` for fire-and-forget operations
- Prefer `async/await` over `.then()` chains
- Handle `DioException` specifically in repository layer

## Feature Scope Lifecycle
Feature scopes are created when route is entered and disposed when navigated away:
```dart
Provider<IAuthScope>(
  create: AuthScope.create,
  dispose: (ctx, scope) => scope.dispose(),
  child: this,
)
```

Always implement `IDisposableObject` on scopes that need cleanup.
