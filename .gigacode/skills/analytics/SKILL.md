# Analytics & Logging Guidelines

## Logging with ILogWriter

### Interface

`ILogWriter` is the single source of truth for logging in the application:

```dart
abstract interface class ILogWriter {
  void log(String message);
  void exception(Object exception, [StackTrace? stackTrace]);
  void failure(Failure failure);
}
```

### Access

`ILogWriter` is injected via DI and accessible through `IAppScope`:
```dart
final logger = appScope.logger;
// or
final logger = context.read<IAppScope>().logger;
```

### Usage Patterns

#### In Repositories (recommended)

Log exceptions in `makeCall()` wrapper — this is handled automatically by `BaseRepository`:
```dart
RequestOperation<T, Failure> makeCall<T, E extends ApiFailure>(
  OperationWrapper<T, E> request,
) async {
  try {
    return ResultOk(await request());
  } on DioException catch (exception, s) {
    logWriter.exception(exception, s);  // Automatic in BaseRepository
    return Result.failed(mapApiError(exception, trace: s));
  }
}
```

#### In WidgetModels / Services

```dart
final class MyService {
  final ILogWriter _logWriter;

  Future<void> doSomething() async {
    try {
      // ... business logic
    } on Exception catch (e, s) {
      _logWriter.exception(e, s);
      // handle or rethrow
    }
  }
}
```

#### Logging Failures

```dart
_logWriter.failure(failure);
```

### Logging Best Practices

- You SHOULD inject `ILogWriter` via constructor, not create instances
- You SHOULD log exceptions with stack traces: `logWriter.exception(e, s)`
- You SHOULD log failures for domain-level errors: `logWriter.failure(failure)`
- You SHOULD use `log()` for informational messages (debug only)
- You SHOULD NOT log sensitive data (tokens, passwords, personal info)
- You SHOULD log at the repository/service level, not in every widget

## Analytics Events

### Architecture

Analytics follows an event-driven pattern:

```
AnalyticEvent (interface)
  ├── HasId (event identifier)
  └── HasMapParams (event parameters)
```

### Creating Analytics Events

#### 1. Define Event Identifier

Add to `lib/common/utils/analytics/ids_analytics_events.dart`:
```dart
enum IdsAnalyticsEvents {
  // Existing events...
  myFeatureScreenView(id: 'my_feature_screen_view'),
  myFeatureButtonPressed(id: 'my_feature_button_pressed');

  final String id;
  const IdsAnalyticsEvents({required this.id});
}
```

#### 2. Create Event Class

```dart
// lib/common/utils/analytics/event/my_feature/my_event.dart

class MyEvent implements AnalyticEvent {
  @override
  String get id => IdsAnalyticsEvents.myFeatureButtonPressed.id;

  @override
  Map<String, Object?> get params => {
        'screen_name': _screenName,
        'button_id': _buttonId,
      };

  final String _screenName;
  final String _buttonId;

  const MyEvent(this._screenName, this._buttonId);
}
```

#### 3. Track the Event

```dart
// In WidgetModel or service
void onButtonPressed() {
  // Track analytics
  final event = MyEvent('MyScreen', 'submit_button');
  // Send via analytics service
}
```

### Analytics Best Practices

- You SHOULD define event IDs as enum values in `IdsAnalyticsEvents`
- You SHOULD create a dedicated event class for each analytics event
- You SHOULD include relevant context in event params
- You SHOULD use meaningful param keys (snake_case)
- You SHOULD NOT track sensitive user data in analytics events

## Snack Queue

### Purpose

SnackQueue manages queued snack bar notifications for the user. It processes snacks sequentially (one at a time) and clears the queue on navigation.

### Access

```dart
final controller = SnackQueueProvider.of(context);
```

### Message Types

```dart
enum SnackMessageType {
  success,   // Gray color (gray700)
  error,     // Error color (error900), NOT auto-hidden
  warning,   // Warning color (warning900)
}
```

### Showing Snacks

```dart
SnackQueueProvider.of(context).addSnack(
  'Operation completed',
  messageType: SnackMessageType.success,
);
```

### Error Handling Integration

Errors are automatically shown via `BaseWidgetModel.onErrorHandle()`:
```dart
@override
void onErrorHandle(Object error) {
  switch (error) {
    case NoInternetFailure():
      _showSnack(message: l10n.noInternetConnection);
    case TimeoutFailure():
      _showSnack(message: l10n.timeoutError);
    case ServerInternalFailure():
      _showSnack(message: l10n.somethingWentWrong);
    case ApiFailure():
      final snackMessage = error.firstInfoMessage ?? l10n.somethingWentWrong;
      _showSnack(message: snackMessage);
  }
}
```

### Snack Queue Features

- **Sequential processing**: Waits for current snack to finish before showing next
- **Router-aware**: Clears queue on navigation changes
- **Error persistence**: Error snacks are NOT auto-hidden
- **Platform-specific rendering**: Full-width bar on mobile, centered card on desktop

### Snack Queue Best Practices

- You SHOULD use `SnackQueueProvider.of(context).addSnack()` for user notifications
- You SHOULD use `SnackMessageType.error` for errors, `success` for success, `warning` for warnings
- You SHOULD NOT manually manage snack queue — use the provider
- You SHOULD rely on `BaseWidgetModel.onErrorHandle()` for automatic error display
- You SHOULD provide localized messages to snacks
- You SHOULD NOT show more than 1-2 snacks in quick succession (queue handles this)

## Logging vs Analytics vs Snacks

| Concern | Mechanism | Audience |
|---------|-----------|----------|
| Debug info | `ILogWriter.log()` | Developers |
| Exceptions | `ILogWriter.exception()` | Developers + Crashlytics |
| Domain failures | `ILogWriter.failure()` | Developers |
| User behavior | Analytics events | Product/Analytics |
| User feedback | SnackQueue | End users |

## Best Practices Summary

- You SHOULD inject `ILogWriter` via constructor for logging
- You SHOULD log exceptions with stack traces in catch blocks
- You SHOULD define analytics event IDs as enum values
- You SHOULD create dedicated event classes with relevant params
- You SHOULD use SnackQueue for all user-facing notifications
- You SHOULD use appropriate `SnackMessageType` for different notification types
- You SHOULD NOT log or track sensitive data (tokens, passwords, PII)
- You SHOULD rely on `BaseWidgetModel.onErrorHandle()` for automatic error snacks
- You SHOULD NOT create snack bars manually — always use SnackQueueProvider
