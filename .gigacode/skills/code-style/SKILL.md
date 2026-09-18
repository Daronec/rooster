# Project Code Style

## Dart 3 Features
- You SHOULD use pattern matching when possible
- You SHOULD use `abstract interface class` for interfaces
- You SHOULD always add a blank line before `return` statements

## Code Quality
- Project uses Dart Code Metrics for code styling and linting
- You SHOULD follow rules in:
  - `dart.yaml`, `flutter.yaml`, `intl.yaml`, `provider.yaml`, `pub.yaml`
- You SHOULD prioritize linting rules from `analysis.yaml`

## TODO Comments
- Format MUST be: `// TODO(someone): description`
- You SHOULD follow this exact pattern to avoid lint issues

## Entity/DTO Classes
- You SHOULD NEVER use both json_serializable and freezed in the same entity
- You SHOULD use only one serialization approach per class
- You SHOULD use new syntax for generating freezed files
- See examples:
  - Entity: `lib/example/features/example/domain/entities/example_entity.dart`
  - DTO: `lib/example/api/data/example_dto.dart`

## General Rules
- You SHOULD NEVER include types for static or local variables
- You SHOULD NEVER use relative imports
- You SHOULD NEVER use assertions (provide defaults or use `?.` instead)
- You SHOULD format comments like sentences with periods
- You SHOULD use constant constructors when possible
- You SHOULD place public getters before public methods
