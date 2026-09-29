# Project Architecture: rooster (Task Manager)

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
  │   ├── gateways/          # Gateway implementations
  │   ├── mappers/           # Entity mappers/codecs
  │   └── storage/           # Hive storage implementations
  ├── domain/
  │   ├── entities/          # Domain models (some freezed)
  │   ├── repositories/      # Repository interfaces (I*Repository)
  │   ├── gateways/          # Gateway interfaces (I*Gateway)
  │   ├── services/          # Domain service interfaces
  │   ├── use_cases/         # Use case implementations
  │   └── decision/          # Decision-making logic (feasibility)
  └── presentation/
      ├── screens/           # Each screen has 3 files
      │   ├── *_screen.dart  # UI (extends BaseWidget<I*WM>)
      │   ├── *_wm.dart      # Widget Model (extends BaseWidgetModel)
      │   └ *_model.dart     # Business Logic (extends ElementaryModel)
      ├── widgets/           # Screen-specific widgets
      ├── strings/           # Screen-specific strings
      ├── formatters/        # Input formatters
      ├── sounds/            # Sound players
      └ *_flow.dart          # Feature entry point (AutoRoute wrapper)
```

## Three-File-Per-Screen Convention
**Strict convention** — every screen MUST have exactly 3 files:

### 1. `*_screen.dart` — UI Layer
```dart
@RoutePage(name: 'AuthRoute')
class AuthScreen extends BaseWidget<AuthScreenWidgetModel> {
  const AuthScreen({super.key}) : super(authScreenWidgetModelFactory);
  
  @override
  Widget buildDesktop(AuthScreenWidgetModel wm) => AuthScreenDesktop(wm: wm);
  
  @override
  Widget buildMobile(AuthScreenWidgetModel wm) => AuthScreenMobile(wm: wm);
}

AuthScreenWidgetModel authScreenWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  final snack = SnackQueueProvider.of(context);
  return AuthScreenWidgetModel(
    AuthScreenModel(
      authGateway: scope.authGateway,
      authBackendStrategy: scope.authBackendStrategy,
      isLikelyHuaweiOrHonorAndroidForAuthUi: scope.isLikelyHuaweiOrHonorAndroidForAuthUi,
    ),
    snackController: snack,
    logWriter: scope.logger,
    sberIdGateway: scope.sberIdGateway,
  );
}
```

### 2. `*_wm.dart` — Widget Model
```dart
class AuthScreenWidgetModel extends BaseWidgetModel<AuthScreen, AuthScreenModel> {
  AuthScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required ISberIdGateway sberIdGateway,
  }) : bodyState = UnionStateNotifier<EmptyScreenBody>(EmptyScreenBody.instance),
       _sberIdGateway = sberIdGateway,
       super(handledFailureLogWriter: logWriter);

  // Navigation, UI state, user actions
  // Uses UnionStateNotifier for complex UI states
  // Access scope via: context.read<IAppScope>()
}
```

### 3. `*_model.dart` — Business Logic
```dart
class AuthScreenModel extends ElementaryModel {
  AuthScreenModel({
    required IAuthGateway authGateway,
    required AuthBackendStrategy authBackendStrategy,
    required bool isLikelyHuaweiOrHonorAndroidForAuthUi,
  }) : _authGateway = authGateway, ...;

  // Pure business logic, data transformations
  // Uses gateway methods, streams, etc.
}
```

## Dependency Injection
**Provider-based DI with single-root scope hierarchy**

### Root Scope (`IAppScope`)
Defined in `lib/features/app/di/app_scope.dart`:
```dart
abstract interface class IAppScope {
  Environment get env;
  AppConfig get appConfig;
  SharedPreferences get sharedPreferences;
  ILogWriter get logger;
  FlutterLocalNotificationsPlugin get localNotificationsPlugin;
  ITokenStorage get tokenStorage;
  IPinCodeStorage get pinCodeStorage;
  AuthBackendStrategy get authBackendStrategy;
  bool get isLikelyHuaweiOrHonorAndroidForAuthUi;
  IAuthGateway get authGateway;
  ISberIdGateway get sberIdGateway;
  IProfileAvatarGateway get profileAvatarGateway;
  IProfilePersonalDataGateway get profilePersonalDataGateway;
  ITeamsGateway get teamsGateway;
  ITasksRepository get tasksRepository;
  ITaskListsRepository get taskListsRepository;
  IPlanningRepository get planningRepository;
  ITaskChangeHistoryRepository get taskChangeHistoryRepository;
  IBudgetRepository get budgetRepository;
  IMaterialStockRepository get materialStockRepository;
  ResolveTaskFeasibilityUseCase get resolveTaskFeasibilityUseCase;
  ListTodayReadyTasksUseCase get listTodayReadyTasksUseCase;
  ListBlockedTasksWithReasonsUseCase get listBlockedTasksWithReasonsUseCase;
  CompleteTaskAndConsumeStockMaterialsUseCase get completeTaskAndConsumeStockMaterialsUseCase;
  ITasksScreenExpandedGroupStorage get tasksScreenExpandedGroupStorage;
  ITaskLocalImageGateway get taskLocalImageGateway;
  ISyncQueue get syncQueue;
  ISyncManager get syncManager;
  Listenable get syncEngineListenable;
  IConnectivityGateway get connectivityGateway;
  ILocalLLMGateway? get localLLMGateway;
}
```

Built by `AppScopeRegister.createScope()` in `lib/features/app/di/app_scope_register.dart`.

### Feature-Level Scopes (Limited)
Only a few features have their own scopes (e.g., `ILocaleScope`, `IThemeModeScope`):
```dart
// locale_scope.dart
abstract interface class ILocaleScope { ... }

// theme_mode_scope.dart
abstract interface class IThemeModeScope { ... }
```

Most features access dependencies directly from `IAppScope` via `context.read<IAppScope>()`.

### App-Level Provider Setup
In `lib/features/app/app_flow.dart`:
```dart
MultiProvider(
  providers: [
    Provider<IAppScope>(create: (_) => appScope),
    ChangeNotifierProvider<AppRouter>(create: (_) => router),
    ProxyProvider2<IAppScope, AppRouter, DeepLinksCoordinator>(...),
  ],
  child: ThemeModeProvider(
    child: LocaleProvider(
      child: App(),
    ),
  ),
)
```

## Data Layer
- **Repository Pattern**: All data access through repositories implementing `I*Repository` interfaces
- **Result Handling**: Direct `Future<T>` or `Stream<T>` returns (no Result monad like velosimulator)
- **Mappers**: `*EntityCodec` classes using hive_flutter adapters for serialization
- **Gateways**: `I*Gateway` interfaces for external services (auth, profile, notifications, etc.)
- **Use Cases**: Domain-level business logic in `domain/use_cases/`

## Networking
- **Library**: Dio (v5.9.2) + fresh_dio for token refresh
- **Configuration**: `lib/api/app_dio_configurator.dart`
- **Appwrite SDK**: appwrite (v23.0.0) for auth and data operations
- **Error Handling**: Gateway implementations handle Appwrite exceptions
- **Custom Client**: Retrofit for API clients where needed

## Offline-First Sync
- **Persistence**: Hive (via `hive_flutter`)
- **Sync Queue**: `ISyncQueue` interface with FIFO operations stored in Hive
- **Sync Manager**: `ISyncManager` monitors connectivity, processes queue with exponential backoff
- **Pattern**: Save to Hive first → update UI → enqueue sync operation
- **Merge Policies**: Domain-level merge policies for conflict resolution (e.g., `task_remote_merge_policy.dart`)

## Routing
- **Library**: auto_route (v11.1.0)
- **Router**: `lib/features/navigation/app_router.dart`
- **Route Name Convention**: `Flow|Screen|Widget` suffix → `Route` prefix
  - `AuthFlow` → `AuthFlowRoute`
  - `AuthScreen` → `AuthRoute`
- **Route Paths**: `lib/app_routing/app_route_paths.dart`
- **Navigation from WM**: `context.router.push(SomeRoute())`
- **Route Args**: Generated `*RouteArgs` classes for passing parameters
- **Platform-Specific Routers**: `AppMobileRouter` and `AppDesktopRouter` (extends `AppRouter`)
- **Navigation Guards**: `auth_guard.dart` for protected routes
- **Desktop Shell**: `main_desktop_shell_screen.dart` with sidebar navigation

## UI Kit
Located in `lib/uikit/`:
- `colors/` — Color scheme (ThemeExtension)
- `text/` — Text styles and fonts
- `sizes/` — `AppSizes` (mobile breakpoint: 800px)
- `buttons/` — Button components
- `scaffold/` — Scaffold wrappers
- `fields/` — Text fields with validators/formatters
- `alerts/` — Dialogs, bottom sheets
- `progress/` — Progress indicators
- `layout_helpers/` — Layout utilities

## Desktop/Mobile Adaptive UI
**Platform-specific widgets pattern:**
```
lib/features/<feature>/presentation/screens/<screen>/widgets/
  ├── <screen>_screen_mobile.dart
  ├── <screen>_screen_desktop.dart
  ├── mobile/
  │   └── <screen>_mobile_content.dart
  └── desktop/
      └── <screen>_desktop_content.dart
```

Each screen implements:
```dart
@override
Widget buildDesktop(Wm wm) => ScreenDesktop(wm: wm);

@override
Widget buildMobile(Wm wm) => ScreenMobile(wm: wm);
```

## Configuration
- **Environment**: `.env` files via `flutter_dotenv`
- **Build Types**: `Environment` enum (dev/prod)
- **Env Config**: `lib/config/environment/environment.dart`
- **App Config**: `lib/config/app_config.dart`

## Localization
- **Framework**: `flutter_i18n` (v0.37.1) with JSON files
- **Files**: `assets/flutter_i18n/en.json`, `assets/flutter_i18n/ru.json`
- **Locales**: `en`, `ru`
- **Usage**: `FlutterI18n.translate(context, 'key')` or `FlutterI18n.of(context).translate('key')`

## Code Generation Tools
- `freezed` — Immutable data classes (`freezed_annotation`)
- `json_serializable` — JSON serialization (`json_annotation`)
- `auto_route` — Navigation code generation
- `theme_tailor` — Theme extension code generation
- `retrofit` — Type-safe HTTP client generation
- `vector_graphics` — SVG icons compilation

## Key Dependencies
- **State Management**: `elementary` (MVVM), `provider` (DI)
- **Persistence**: `hive`, `hive_flutter`, `flutter_secure_storage`
- **Networking**: `dio`, `fresh_dio`, `appwrite`, `retrofit`
- **Navigation**: `auto_route`
- **Reactive**: `rxdart`
- **Utilities**: `collection`, `equatable`, `uuid`, `intl`, `rxdart`
- **Platform**: `device_info_plus`, `flutter_local_notifications`, `app_links` (deep links)
- **Media**: `image_picker`, `image`, `audioplayers`
- **ML/AI**: `ffi`, `ffigen` (for local LLM bindings)

## Auth Strategy
**Dual backend strategy** (see `docs/AUTH_DUAL_STRATEGY_PLAN.md`):
- **Appwrite**: Full cloud sync with OAuth (Google/Apple/Sber ID)
- **Offline-only**: Local-only mode for devices without cloud access (Huawei/Honor without GMS)
- **Strategy Selection**: `AuthBackendStrategy` enum determines backend behavior
- **Device Detection**: `isLikelyHuaweiOrHonorAndroidForAuthUi` flag affects UI presentation

## Feature Domains
1. **auth** — Authentication (Appwrite, Sber ID, offline)
2. **tasks** — Task management (CRUD, lists, dependencies, decisions)
3. **planning** — Task planning and scheduling
4. **profile** — User profile and teams
5. **ai** — Local LLM integration (chat, model management)
6. **settings** — App settings
7. **dev_panel** — Developer diagnostics panel
8. **app** — App initialization, DI setup
9. **navigation** — Routing configuration
10. **locale_mode** — Locale/language settings
11. **theme_mode** — Theme/dark mode settings
