# Utilities Guidelines

## Directory Structure

```
lib/util/
  extensions/          # Type extensions (_x.dart files)
  formatters/          # Text input formatters
  app_consts.dart      # Central constants
  app_typedefs.dart    # Type definitions
  clipboard_util.dart  # Clipboard helpers
  url_launch_util.dart # URL launching
  version_util.dart    # Version comparison
  file_picker_util.dart
  download_file_web.dart
  system_chrome_util.dart
  time_zone_util.dart
  tradecode_set_helper.dart
  test_env_detector.dart

lib/common/utils/
  analytics/           # Analytics service
  disposable_object/   # IDisposableObject pattern
  logger/              # ILogWriter interface
  snack_queue/         # Snack bar queue system
```

## Extensions Pattern

### Naming Convention

- File: `<type>_x.dart` (e.g., `date_time_x.dart`, `string_extension.dart`)
- Extension: `<Type>X` (e.g., `DateTimeX`, `IterableX`)

### Creating Extensions

```dart
// lib/util/extensions/my_type_x.dart

extension MyTypeX on MyType {
  String format() {
    return 'formatted: $this';
  }
  
  bool isValid() {
    return this.isNotEmpty;
  }
}
```

### Existing Extensions

- `DateTimeX` — DateTime formatting, comparison, range utilities
- `IterableX` — `separated(separator)` for iterable joining
- `StringExtension` — `capitalize()`
- `DoubleX` — `toPrettySize()` (KB/MB conversion)
- `ColorX` — `ColorFilter.opacity()` factory
- `ValueNotifierX` — `emit()`, `UnionState` helpers, `PageStateNotifier`
- `Closure extensions` — `let`, `run`, `also` for any object

### Extension Best Practices

- You SHOULD keep extensions pure (no side effects)
- You SHOULD name files with `_x.dart` suffix
- You SHOULD group related methods in one extension
- You SHOULD use extensions for convenience methods on existing types
- You SHOULD NOT use extensions to override framework behavior

## Utility Classes

### Naming Convention

- File: `<purpose>_util.dart`
- Class: `<Purpose>Util` with private constructor

### Creating Utility Classes

```dart
// lib/util/my_util.dart

class MyUtil {
  const MyUtil._();  // Prevents instantiation
  
  static bool isValid(String value) {
    return value.isNotEmpty;
  }
  
  static String format(String value) {
    return value.trim();
  }
}
```

### Utility Best Practices

- You SHOULD use `const ClassName._()` to prevent instantiation
- You SHOULD use static methods only
- You SHOULD place utilities in `lib/util/`
- You SHOULD NOT create instance methods in utility classes
- You SHOULD document utility methods that aren't self-explanatory

## Formatters

### Location

All text input formatters are in `lib/util/formatters/`.

### Creating Formatters

```dart
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Apply phone number mask
    return newValue;
  }
}
```

### Best Practices

- You SHOULD place formatters in `lib/util/formatters/`
- You SHOULD use formatters for input masking (phone, email, etc.)
- You SHOULD combine with validators from `lib/uikit/fields/validators/`

## Constants

### Location

All app-wide constants are in `lib/util/app_consts.dart`.

### Types of Constants

- ADFS auth settings
- Animation durations
- Screen size thresholds
- Table column counts
- Version strings
- Store links (App Store, Google Play)

### Best Practices

- You SHOULD add new constants to `app_consts.dart`
- You SHOULD group related constants with comments
- You SHOULD NOT hardcode magic numbers in feature code
- You SHOULD use `AppSizes` from uikit for UI-related dimensions

## Typedefs

### Location

`lib/util/app_typedefs.dart`

### Existing Typedefs

```dart
// Union state listenable type
typedef UnionStateListenable<T> = ValueListenable<UnionState<T>>;
```

### Best Practices

- You SHOULD place shared type definitions in `app_typedefs.dart`
- You SHOULD use typedefs for complex function signatures
- You SHOULD document what each typedef represents

## Common Utilities

### DisposableObject Pattern

Located in `lib/common/utils/disposable_object/`:

```dart
abstract class IDisposableObject {
  void dispose();
}

abstract class DisposableObject implements IDisposableObject {
  bool _disposed = false;
  
  @override
  @mustCallSuper
  void dispose() {
    assert(!_disposed, 'Already disposed');
    _disposed = true;
  }
}
```

Use this for objects that need cleanup. Never call `dispose()` twice.

### When to Create New Utilities

- **Extensions**: When adding convenience methods to existing Dart/Flutter types
- **Utility classes**: When you need static-only helpers that don't belong to a type
- **Formatters**: For input masking in text fields
- **Constants**: For app-wide magic numbers and configuration values
- **Common utils**: For cross-cutting infrastructure (logging, analytics, snack queue)

### When NOT to Create Utilities

- Business logic belongs in domain layer
- UI components belong in uikit or feature presentation layer
- API logic belongs in api layer
- Feature-specific helpers belong in the feature's data/domain layer

## Utility Best Practices

- You SHOULD keep utilities focused on a single responsibility
- You SHOULD prefer extensions for type-specific convenience methods
- You SHOULD prefer utility classes for standalone helper functions
- You SHOULD NOT create utilities for business logic
- You SHOULD document utility methods that aren't self-explanatory
- You SHOULD write tests for utility functions (see testing skill)
- You SHOULD follow the naming conventions: `<type>_x.dart`, `<Type>X`, `<Type>Util`
