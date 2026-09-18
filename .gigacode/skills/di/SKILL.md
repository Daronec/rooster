# Scope Implementation Rules

## Basic Structure

Every scope MUST follow this pattern:

```dart
/// {@template feature_name_scope.class}
/// Implementation of [IFeatureNameScope].
/// {@endtemplate}
final class FeatureNameScope extends DisposableObject implements IFeatureNameScope {
  // Implementation
}

/// Scope dependencies of the FeatureName feature.
abstract interface class IFeatureNameScope implements IDisposableObject {
  // Interface definition
}
```

## Key Requirements

### Class Declaration
- You MUST use `final class` for scope implementation
- You MUST extend `DisposableObject`
- You MUST implement corresponding interface

### Factory Constructor
- You MUST name it `create`
- You MUST accept `BuildContext context` as first parameter
- You MUST read `IAppScope` from context

### Interface Definition
- You MUST use `abstract interface class`
- You MUST implement `IDisposableObject`
- You MUST define all required dependencies as getters

### Documentation
- You SHOULD include template documentation for the class
- You SHOULD document the scope's purpose
- You SHOULD document all dependencies

## Dependency Management

- You SHOULD declare repositories as `final` fields
- You SHOULD initialize all dependencies in constructor
- You MUST dispose all disposable dependencies

## Disposal Rules

```dart
@override
void dispose() {
  // Dispose dependencies
  dependency.dispose();
  
  // Always call super.dispose() last
  super.dispose();
}
```

## Best Practices
- You SHOULD use factory constructor for dependency creation
- You SHOULD keep constructor simple with direct field initialization
- You SHOULD handle errors in repository layer
- You SHOULD make dependencies easily mockable

## Naming Conventions

- Scope class name: `FeatureNameScope`
- Interface name: `IFeatureNameScope`
- File location: `lib/features/feature_name/di/feature_name_scope.dart`

## Example Implementation

```dart
/// {@template example_scope.class}
/// Implementation of [IExampleScope].
/// {@endtemplate}
final class ExampleScope extends DisposableObject implements IExampleScope {
  @override
  final IExampleRepository repository;

  /// Factory constructor for [IExampleScope].
  factory ExampleScope.create(BuildContext context) {
    final appScope = context.read<IAppScope>();

    final repository = ExampleRepository(
      api: ExampleApi(appScope.authDio),
      converter: const ExampleConverter(),
      logWriter: appScope.logger,
    );

    return ExampleScope(repository);
  }

  /// {@macro example_scope.class}
  ExampleScope(this.repository);

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }
}

/// Scope dependencies of the Example feature.
abstract interface class IExampleScope implements IDisposableObject {
  /// ExampleRepository.
  IExampleRepository get repository;
}
