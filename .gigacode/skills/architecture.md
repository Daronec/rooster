# Project Architecture: client_velo_app

## Architecture Pattern
**Elementary MVVM + Provider DI + Clean Architecture (Feature-Sliced)**

The project uses Elementary library (v3.2.1) for MVVM pattern, layered on Clean Architecture principles with clear domain/data/presentation separation.

## Feature Structure
Each feature lives in `lib/features/<feature_name>/` with this structure:
```
lib/features/<feature_name>/
  ├── data/
  │   ├── repositories/      # Concrete repository implementations
  │   ├── services/          # External service clients
  │   └── converters/        # Data-to-entity converters (MapConverter)
  ├── domain/
  │   ├── entities/          # Domain models (some freezed)
  │   ├── repositories/      # Repository interfaces (I*Repository)
  │   └── services/          # Domain service interfaces
  ├── di/
  │   └ *_scope.dart         # Feature-scoped DI container (I*Scope)
  └── presentation/
      ├── screens/           # Each screen has 3 files
      │   ├── *_screen.dart  # UI (extends BaseWidget<I*WM>)
      │   ├── *_wm.dart      # Widget Model (extends BaseWidgetModel)
      │   └ *_model.dart     # Business Logic (extends ElementaryModel)
      ├── widgets/           # Screen-specific widgets
      ├── strings/           # Screen-specific strings
      └ *_flow.dart          # Feature entry point (AutoRoute wrapper)
```

## Three-File-Per-Screen Convention
**Strict convention** — every screen MUST have exactly 3 files:

### 1. `*_screen.dart` — UI Layer
```dart
class LoginScreen extends BaseWidget<ILoginWM> {
  @override
  Widget buildMobile(ILoginWM wm) { /* mobile layout */ }
  
  @override
  Widget buildDesktop(ILoginWM wm) => buildMobile(wm); // or custom
}
```

### 2. `*_wm.dart` — Widget Model
```dart
class LoginWM extends BaseWidgetModel<LoginFlow, ILoginWM> with _$LoginWM {
  // Navigation, UI state, user actions
  // Uses ValueNotifier<bool> for loading states
  // Access scope via: context.read<IAuthScope>()
}

ILoginWM defaultLoginWMFactory(BuildContext context) {
  final scope = context.read<IAuthScope>();
  final snackController = SnackQueueProvider.of(context);
  return LoginWM(
    LoginModel(repository: scope.repository, onLoginSuccess: () {}),
    snackController: snackController,
  );
}
```

### 3. `*_model.dart` — Business Logic
```dart
class LoginModel extends ElementaryModel implements ILoginModel {
  // Pure business logic, data transformations
  // Uses repository methods, streams, etc.
}
```

## Dependency Injection
**Provider-based DI with two-level scope hierarchy**

### Level 1: App Scope (`IAppScope`)
Defined in `lib/features/app/di/app_scope.dart`:
```dart
abstract interface class IAppScope {
  Environment get env;
  AppConfig get appConfig;
  SharedPreferences get sharedPreferences;
  ILogWriter get logger;
  ITokenStorage get tokenStorage;
  IPinCodeStorage get pinCodeStorage;
  IConnectivityGateway get connectivityGateway;
  ISberCloudKVClient? get sberCloudKVClient;
}
```

Built by `AppScopeRegister.createScope()` in `lib/features/app/di/app_scope_register.dart`.

### Level 2: Feature Scopes
Each feature has its own scope (e.g., `IAuthScope`, `IProfileScope`):
```dart
abstract interface class IAuthScope implements IDisposableObject {
  IAuthRepository get repository;
}

factory AuthScope.create(BuildContext context) {
  final appScope = context.read<IAppScope>();
  final repository = AuthRepository(
    logWriter: appScope.logger,
    kvClient: appScope.sberCloudKVClient,
    tokenStorage: appScope.tokenStorage as TokenStorageImpl,
  );
  return AuthScope(repository);
}
```

### Feature Scope Registration via AutoRoute Wrapper
```dart
@override
Widget wrappedRoute(BuildContext context) {
  return Provider<IAuthScope>(
    create: AuthScope.create,
    dispose: (ctx, scope) => scope.dispose(),
    child: this,
  );
}
```

### App-Level Provider Setup
In `lib/features/app/app_flow.dart`:
```dart
MultiProvider(
  providers: [
    Provider<IAppScope>(create: (_) => appScope),
    ChangeNotifierProvider<AppRouter>(create: (_) => AppRouter()),
  ],
  child: ThemeModeProvider(child: LocaleProvider(child: App())),
)
```

## Data Layer
- **Repository Pattern**: All data access through repositories extending `BaseRepository`
- **Result Monad**: Custom `Result<TData, TErr>` sealed class (ok/failed)
- **RequestOperation**: `typedef RequestOperation<T, F> = Future<Result<T, F>>`
- **Converters**: `*MapConverter` classes with `fromMap()` / `toMap()` static methods

## Networking
- **Library**: Dio (v5.11.1) + fresh_dio for token refresh
- **Configuration**: `lib/api/app_dio_configurator.dart`
- **DTOs**: Located in `lib/api/data/`, JSON via `json_serializable` (.g.dart)
- **Error Handling**: DioException → Failure subclasses (TimeoutFailure, NoInternetFailure, ApiFailure)
- **Custom Client**: `SberCloudKVClient` for REST calls

## Offline-First Sync
- **Persistence**: Hive (via `hive_flutter`)
- **Sync Queue**: `ISyncQueue` interface with FIFO operations stored in Hive
- **Sync Manager**: `SyncManagerImpl` monitors connectivity, processes queue with exponential backoff
- **Pattern**: Save to Hive first → update UI → enqueue sync operation

```dart
Future<void> saveProfile(UserProfileEntity profile) async {
  await _persistProfile(profile);      // Hive write first
  _profile.value = profile;             // UI update immediately
  _enqueueSync(type: SyncOperationType.upsertUserProfile, payload: ...);
}
```

## Routing
- **Library**: auto_route (v11.1.0)
- **Router**: `lib/features/navigation/app_router.dart`
- **Route Name Convention**: `Flow|Screen|Widget` suffix → `Route` prefix
  - `AuthFlow` → `AuthFlowRoute`
  - `LoginScreen` → `LoginRoute`
- **Route Paths**: `lib/app_routing/app_route_paths.dart`
- **Navigation from WM**: `context.router.push(SomeRoute())`
- **Route Args**: Generated `*RouteArgs` classes for passing parameters

## UI Kit
Located in `lib/uikit/`:
- `colors/` — `AppColorScheme` (ThemeExtension + theme_tailor)
- `text/` — `AppTextScheme`, font styles
- `sizes/` — `AppSizes` (ThemeExtension)
- `buttons/` — Primary, Black, Gray, Pushable buttons
- `scaffold/` — `AppScaffold`, `DefaultAppBar`
- `fields/` — Text fields with validators/formatters
- `alerts/` — Dialogs, bottom sheets
- `progress/` — Progress bars
- `layout_helpers/` — Height, Width, SmoothBorderWrapper
- `themes/` — Theme configurations

## Configuration
- **Environment**: `.env` files via `flutter_dotenv`
- **Build Types**: `dev` / `prod` enum
- **Env Config**: `lib/config/app_dotenv.dart` — static getters for env vars
- **External KV**: SberCloud KV client for remote config

## Localization
- **Framework**: Flutter built-in l10n with ARB files
- **Files**: `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`
- **Locales**: `en`, `ru`
- **Usage**: `AppLocalizations.of(context).translateKey`

## Code Generation Tools
- `freezed` — Immutable data classes
- `json_serializable` — JSON serialization
- `auto_route` — Navigation code generation
- `theme_tailor` — Theme extension code generation
