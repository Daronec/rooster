# Project Architecture

## Core Principles

- You SHOULD follow the three-file-per-screen convention: `*_screen.dart`, `*_wm.dart`, `*_model.dart`
- You SHOULD access dependencies from `IAppScope` via `context.read<IAppScope>()`
- You SHOULD implement platform-specific UI in `widgets/desktop/` and `widgets/mobile/` subdirectories
- You SHOULD use `BaseWidget<Wm>` for screens and `BaseWidgetModel` for widget models
- You SHOULD extend `ElementaryModel` for pure business logic
- You SHOULD use `UnionState`/`UnionStateNotifier` for complex UI states (not simple loading booleans)
- You SHOULD follow the route naming convention: `Flow|Screen|Widget` suffix → `Route` prefix

## Screen Structure

Every screen MUST have exactly 3 files:

### `*_screen.dart`
- Extends `BaseWidget<Wm>`
- Implements `buildDesktop()` and `buildMobile()`
- Contains factory function for WM creation
- Uses `@RoutePage(name: '...Route')` annotation

### `*_wm.dart`
- Extends `BaseWidgetModel<Screen, Model>`
- Handles navigation, UI state, user actions
- Uses `UnionStateNotifier` for complex states
- Access scope via `context.read<IAppScope>()`

### `*_model.dart`
- Extends `ElementaryModel`
- Contains pure business logic
- Uses gateways and repositories from constructor

## Feature Structure

Each feature lives in `lib/features/<feature_name>/`:
```
lib/features/<feature_name>/
  ├── data/          # repositories, gateways, mappers, storage
  ├── domain/        # entities, repositories (interfaces), gateways, use_cases
  └── presentation/  # screens, widgets, strings, flows
```

## Dependency Injection

- **Root Scope**: `IAppScope` in `lib/features/app/di/app_scope.dart`
- **Access**: `context.read<IAppScope>()` in WM factory functions
- **Scope Implementation**: `AppScope` class with all dependencies
- **Setup**: `AppFlow` widget in `lib/features/app/app_flow.dart` uses `MultiProvider`

## Data Layer

- **Repositories**: Implement `I*Repository` interfaces
- **Gateways**: Implement `I*Gateway` interfaces for external services
- **Mappers**: Use `*EntityCodec` with Hive adapters for serialization
- **No Result monad**: Direct `Future<T>` or `Stream<T>` returns

## Networking

- **Appwrite SDK**: `appwrite` (v23.0.0) for auth and data
- **Dio**: `dio` + `fresh_dio` for custom API calls
- **Retrofit**: `retrofit_generator` for type-safe clients

## Offline-First Pattern

- **Persistence**: Hive for local storage
- **Sync Queue**: `ISyncQueue` for pending operations
- **Sync Manager**: `ISyncManager` handles connectivity and retry logic
- **Merge Policies**: Domain-level merge policies for conflict resolution

## Adaptive UI

- **Desktop**: Width > 800px, uses `AppDesktopRouter`
- **Mobile**: Width <= 800px, uses `AppMobileRouter`
- **Platform Widgets**: Separate `widgets/desktop/` and `widgets/mobile/` directories
- **Shell Navigation**: Desktop uses sidebar navigation (`main_desktop_shell_screen.dart`)

## Localization

- **Framework**: `flutter_i18n` with JSON files
- **Files**: `assets/flutter_i18n/en.json`, `assets/flutter_i18n/ru.json`
- **Usage**: `FlutterI18n.translate(context, 'key')`

## Code Generation

- `freezed` — Immutable data classes
- `json_serializable` — JSON serialization
- `auto_route` — Navigation code generation
- `theme_tailor` — Theme extension code generation
- `retrofit` — Type-safe HTTP client generation

## Auth Strategy

- **Dual Backend**: Appwrite (cloud) or Offline-only
- **Strategy**: `AuthBackendStrategy` enum
- **Sber ID**: Native SDK integration via `ISberIdGateway`
- **Device Detection**: Huawei/Honor devices get different UI
