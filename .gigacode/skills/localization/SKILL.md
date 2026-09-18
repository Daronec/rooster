# Localization Guidelines

## Configuration

- ARB files are in `lib/l10n/`
- Template ARB file: `app_ru.arb` (Russian is the main locale)
- Config: `l10n.yaml`
- Generated code: `.dart_tool/flutter_gen/gen_l10n/`
- Generated class name: `AppLocalizations`

## Accessing Localizations

### In WidgetModels (recommended)

Access via the `l10n` getter inherited from `BaseWidgetModel`:
```dart
class ExampleModel extends ElementaryModel {
  void doSomething() {
    final message = l10n.someKey;  // Direct access
  }
}
```

### In Widgets

Use the convenience extension on `BuildContext`:
```dart
Text(context.l10n.someKey);
```

### In Utility Functions

Pass `AppLocalizations` explicitly as a parameter:
```dart
String formatTimeLeft({
  required DateTime start,
  required AppLocalizations l10n,
}) {
  return '${l10n.through} $hours ${l10n.shortHour}';
}
```

### Null-Safe Access

When `context` might be unavailable:
```dart
void onErrorHandle(Object error) {
  final translations = AppLocalizations.of(context);
  if (translations == null) return;
  
  switch (error) {
    case NoInternetFailure():
      _showSnack(message: translations.noInternetConnection);
  }
}
```

## ARB File Patterns

### Basic Strings

```arb
"okButton": "OK",
"@okButton": {
  "description": "Text for the OK button"
}
```

### Strings with Placeholders

```arb
"greeting": "Привет, {name}!",
"@greeting": {
  "placeholders": {
    "name": { "type": "String" }
  }
}
```

### Pluralization (ICU Message Format)

```arb
"yearsCount": "{count, plural, one{# год} few{# года} other{# лет}}",
"@yearsCount": {
  "placeholders": {
    "count": { "type": "int" }
  }
}
```

Russian pluralization forms: `zero`, `one`, `few`, `many`, `other`

### Segmentation

Group strings logically using `@segment` comments:
```arb
// @segmentCommon
"okButton": "OK",
"cancelButton": "Отмена",

// @segmentCommonErrors
"noInternetConnection": "Нет подключения к интернету",
"timeoutError": "Превышено время ожидания"

// @segmentExamples
"exampleKey": "Example value"
```

## Generating Localizations

After modifying ARB files:
```bash
make intl_with_format
```

This runs `scripts/intl_with_format.sh` which:
1. Generates `AppLocalizations` class
2. Formats the generated code

## Localization Best Practices

- You SHOULD add all user-facing strings to `app_ru.arb`
- You SHOULD provide descriptions for complex strings (placeholders, pluralization)
- You SHOULD use segmentation (`@segment...`) to organize ARB file
- You SHOULD use placeholders for dynamic content, never string concatenation
- You SHOULD use pluralization for countable items
- You SHOULD NOT hardcode strings in Dart code
- You SHOULD use `context.l10n.key` in widgets, `l10n.key` in WidgetModels
- You SHOULD pass `AppLocalizations` explicitly to utility functions that don't have context
- You SHOULD handle null `AppLocalizations.of(context)` gracefully in error handlers
- You SHOULD document ARB entries with `@key` blocks for complex placeholders

## Common Localization Patterns

### Date/Time Formatting

```arb
"weekDay": "{date}",
"@weekDay": {
  "placeholders": {
    "date": { "type": "DateTime", "format": "E" }
  }
}
```

### Error Messages

Use segment grouping for error-related strings:
```arb
// @segmentCommonErrors
"noInternetConnection": "Нет подключения к интернету",
"timeoutError": "Превышено время ожидания",
"somethingWentWrong": "Что-то пошло не так",
"couldNotLoad": "Не удалось загрузить",
"couldNotLoadMessage": "Проверьте подключение к интернету и попробуйте снова"
```

### Form Labels and Placeholders

```arb
"emailFieldLabel": "Email",
"emailFieldPlaceholder": "Введите email",
"invalidFieldMaxLengthError": "{count, plural, one{Не более 1 символа} other{Не более {count} символов}}",
```

### Confirmations and Actions

```arb
"clearFieldConfirmMessage": "Очистить поле?",
"deleteConfirmMessage": "Удалить?",
"cancelConfirmMessage": "Отменить?"
```
