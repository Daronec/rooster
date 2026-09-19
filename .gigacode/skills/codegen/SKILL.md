# Code Generation Guidelines

## Code Generation Systems

The project uses two complementary code generation systems:

1. **Mason Bricks** — For scaffolding feature/module boilerplate
2. **API Generator** — For generating DTOs, API services, and URL constants from OpenAPI specs

## Mason Bricks

### Configuration

Located in `mason.yaml`:
```yaml
bricks:
  feature:
    path: tools/bricks/feature
  screen:
    path: tools/bricks/screen
  widget:
    path: tools/bricks/widget
```

### Available Bricks

#### `feature` Brick

Creates a complete feature structure with domain/data/presentation/di layers:

```bash
mason make feature -c <feature_name>
```

**Generated structure:**
```
lib/features/<feature_name>/
  data/
    converters/       (.gitkeep)
    repositories/
      <feature>_repository.dart
  di/
    <feature>_scope.dart
  domain/
    entities/         (.gitkeep)
    repositories/
      i_<feature>_repository.dart
  presentation/
    <feature>_flow.dart
    screens/
      <feature>/
        <feature>_model.dart
        <feature>_screen.dart
        <feature>_wm.dart
    widgets/          (.gitkeep)
```

**Generated files include:**
- `I<Feature>Repository` interface extending `IBaseRepository`
- `<Feature>Repository` extending `BaseRepository`
- `<Feature>Scope` with DI setup (DisposableObject pattern)
- `<Feature>Flow` route entry point with `@RoutePage()`
- `<Feature>Model` extending `ElementaryModel`
- `<Feature>Screen` extending `BaseWidget<I<Feature>WM>`
- `<Feature>WM` extending `BaseWidgetModel` with factory

#### `screen` Brick

Adds a screen to an existing feature:

```bash
mason make screen -c feature_name=<feature> -c screen_name=<screen>
```

**Generated structure:**
```
lib/features/<feature>/presentation/screens/<screen>/
  <screen>_model.dart
  <screen>_screen.dart
  <screen>_wm.dart
```

#### `widget` Brick

Adds a widget to an existing feature:

```bash
mason make widget -c feature_name=<feature> -c widget_name=<widget>
```

**Generated structure:**
```
lib/features/<feature>/presentation/widgets/<widget>/
  <widget>_model.dart
  <widget>_widget.dart
  <widget>_wm.dart
```

### When to Use Mason Bricks

- Creating a new feature → use `feature` brick
- Adding a new screen to existing feature → use `screen` brick
- Adding a reusable widget to existing feature → use `widget` brick
- Manual creation is ONLY acceptable for simple one-off widgets

## API Code Generation

### Overview

API code is generated from OpenAPI/Swagger `api.yaml` files using a custom `apple_silicon_generator` with Stencil templates.

### Components

1. **DTO Generation** — Generates `*Dto` classes, enums, and type aliases
2. **Request Generation** — Generates `*Urls` (constants) and `*Api` (Retrofit services)

### Running API Codegen

```bash
make surfgen
```

This runs:
1. `tools/api_generator/dto_codegen.sh` — Generates DTOs
2. `tools/api_generator/request_codegen.sh` — Generates API services

### DTO Generation

**Config:** `tools/api_generator/dto_config.yaml`

Generates into `lib/api/data/`:
- `*Dto` classes from models (using `@JsonSerializable`)
- `*Dto` enums from OpenAPI enums
- `*Type` type aliases from OpenAPI type definitions

**Templates:**
- `retrofit_model.stencil` — DTO classes with `@JsonSerializable(includeIfNull: false)`
- `retrofit_enum.stencil` — Enum classes
- `alias.stencil` — Type aliases

### Request Generation

**Config:** `tools/api_generator/request_config.yaml`

Generates into `lib/api/service/<name>/`:
- `*Urls` classes with static URL constants
- `*Api` abstract Retrofit service classes

**Templates:**
- `urls.stencil` — URL constant classes
- `retrofit_api.stencil` — Retrofit `@RestApi()` abstract classes with HTTP annotations

### Build Runner Codegen

For `json_serializable`, `freezed`, and other `build_runner` generators:

```bash
make codegen
```

This runs:
```bash
fvm flutter pub get &&
fvm flutter pub run build_runner build --delete-conflicting-outputs &&
sh scripts/format.sh
```

### Build Config

**`build.yaml`:**
```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          include_if_null: true
```

## Codegen Workflow

### Full Codegen (after API spec changes)

```bash
make surfgen   # Generate API DTOs and services
make codegen   # Run build_runner for .g.dart files
```

### After Adding/Modifying Annotations

```bash
make codegen   # Run build_runner for freezed, json_serializable, etc.
```

### After Adding Routes

```bash
make codegen   # Regenerates auto_route routes
```

### Codegen Best Practices

- You SHOULD ALWAYS use `make surfgen` after API spec changes
- You SHOULD ALWAYS use `make codegen` after adding/modifying annotations
- You SHOULD NEVER manually edit generated files (`*.g.dart`, `app_router.gr.dart`)
- You SHOULD use Mason bricks for scaffolding new features/screens/widgets
- You SHOULD run `make format` after codegen to format generated code
- You SHOULD check generated files to verify annotations are correct
- You SHOULD commit generated files to version control

## Mason Brick Patterns

### Generated Repository Pattern

```dart
final class ExampleRepository extends BaseRepository implements IExampleRepository {
  final IExampleApi _api;
  final ExampleConverter _converter;
  final ILogWriter _logWriter;

  ExampleRepository({
    required IExampleApi api,
    required ExampleConverter converter,
    required ILogWriter logWriter,
  })  : _api = api,
        _converter = converter,
        _logWriter = logWriter;

  @override
  RequestOperation<ExampleEntity, Failure> fetchData() {
    return makeCall<ExampleEntity, ApiFailure>(() async {
      final result = await _api.getData();
      return _converter.convert(result);
    });
  }
}
```

### Generated Scope Pattern

```dart
final class ExampleScope extends DisposableObject implements IExampleScope {
  @override
  final IExampleRepository repository;

  factory ExampleScope.create(BuildContext context) {
    final appScope = context.read<IAppScope>();
    final repository = ExampleRepository(
      api: ExampleApi(appScope.authDio),
      converter: const ExampleConverter(),
      logWriter: appScope.logger,
    );
    return ExampleScope(repository);
  }

  ExampleScope(this.repository);

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }
}
```

### Generated Screen Pattern

```dart
@RoutePage()
class ExampleScreen extends BaseWidget<IExampleWM> {
  const ExampleScreen({super.key});

  @override
  Widget buildMobile(BuildContext context, IExampleWM wm) {
    return buildMainContent(wm, isDesktop: false);
  }

  @override
  Widget buildDesktop(BuildContext context, IExampleWM wm) {
    return buildMainContent(wm, isDesktop: true);
  }
}
```

## Codegen Best Practices Summary

- You SHOULD use `make surfgen` for API changes (DTOs + services)
- You SHOULD use `make codegen` for annotation changes (freezed, json_serializable)
- You SHOULD use Mason bricks for scaffolding new features/screens/widgets
- You SHOULD NEVER manually edit generated files
- You SHOULD always run `make format` after codegen
- You SHOULD include generated files in version control
- You SHOULD follow the patterns generated by Mason bricks for consistency
