# Error Handling Guidelines

## Error Architecture

The project uses a layered error handling approach:
- **Domain**: `Failure<T>` + `Result<T, F>` types
- **API**: `ApiFailure` with typed subclasses
- **Presentation**: `BaseWidgetModel.onErrorHandle()` + `UnionState`
- **UI**: Error widgets, shimmer loading states, SnackQueue

## Failure Types

### Base Failure

```dart
base class Failure<T extends Exception> implements Exception {
  final T original;
  final StackTrace? trace;
  const Failure({required this.original, required this.trace});
}
```

### API Failures

Located in `lib/core/failures/api_failure.dart`:

```dart
class ApiFailure extends Failure<Exception> {
  final int? statusCode;
  final String? responseBodyCode;
  final String? message;
  
  // Typed boolean getters for business codes
  bool get isPhoneNumberNotFound => responseBodyCode == '4001';
  bool get isOtpExpired => responseBodyCode == '4002';
  bool get isOtpIncorrect => responseBodyCode == '4003';
  bool get isSessionsExceeded => responseBodyCode == '4004';
  bool get isEmptyRequest => responseBodyCode == '4005';
  bool get isAgentAlreadyExists => responseBodyCode == '4006';
  bool get isParametersInvalid => responseBodyCode == '4007';
  bool get isFileUploadFailed => responseBodyCode == '4008';
  bool get isMeetingCreationFailed => responseBodyCode == '4009';
  bool get isDeletionFailed => responseBodyCode == '4010';
  bool get isScheduleViewFailed => responseBodyCode == '4011';
}
```

### Specific Failures

- `NoInternetFailure` — No network connection
- `TimeoutFailure` — Request timeout
- `ServerInternalFailure` — Server error (5xx)

## Result Type

```dart
sealed class Result<TData, TErr extends Failure> {
  const Result();
  
  factory Result.ok(TData data) => ResultOk(data);
  factory Result.failed(TErr failure) => ResultFailed(failure);
  
  T when<T>({
    required T Function(TData data) ok,
    required T Function(TErr failure) failed,
  });
}

final class ResultOk<T, F extends Failure> extends Result<T, F> {
  final T data;
  const ResultOk(this.data);
}

final class ResultFailed<T, F extends Failure> extends Result<T, F> {
  final F failure;
  const ResultFailed(this.failure);
}
```

### Usage

```dart
final result = await repository.fetchData();

result.when(
  ok: (data) {
    // Handle success
    setState(() => state = data);
  },
  failed: (failure) {
    // Handle error
    throw failure;
  },
);
```

## Request Operation Typedefs

```dart
typedef RequestOperation<T, F extends Failure> = Future<Result<T, F>>;
typedef ApiOperation<T> = RequestOperation<T, Failure>;
```

Use `ApiOperation<T>` for API calls without specific error handling.
Use `RequestOperation<T, Failure>` for calls with specific failure types.

## Error Handling in WidgetModels

### Automatic Error Handling

`BaseWidgetModel.onErrorHandle()` automatically shows snack messages for common failures:

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

### Custom Error Handling

Override `onErrorHandle` in your WidgetModel for custom behavior:

```dart
@override
void onErrorHandle(Object error) {
  switch (error) {
    case ApiFailure() when error.isPhoneNumberNotFound:
      _showSnack(message: l10n.phoneNumberNotFound);
    case ApiFailure() when error.isOtpExpired:
      _showSnack(message: l10n.otpExpired);
    default:
      super.onErrorHandle(error);  // Fall back to default handling
  }
}
```

### Custom Error Handler Callback

Pass a custom error handler to the model constructor:

```dart
class MyModel extends ElementaryModel<MyWM> {
  MyModel(
    IRepository repo, {
    required CustomErrorHandler errorHandler,
  }) : super(errorHandler: errorHandler);
}
```

## Error Widgets

### Base Error Widget

Located in `lib/common/widgets/error/base_error_widget.dart`:

```dart
BaseErrorWidget(
  title: 'Error Title',
  description: 'Error description',
  iconAssetName: 'assets/icons/error.svg',
  onRetryPressed: () {},
  buttonLabel: 'Retry',
);
```

### App Error Widget

Generic error widget for general use:
```dart
AppErrorWidget(
  error: exception,
  onRetryPressed: () {},
);
```

### Feature-Specific Error Widgets

- `AppNextPageErrorWidget` — For paginated list errors
- `AppCarouselError` — For carousel components
- `SearchNextPageErrorWidget` — For search errors
- `TableErrorWidget` — For table first-page load errors
- `TableLoadMoreErrorWidget` — For table subsequent page errors

### Error Widget Best Practices

- You SHOULD use feature-specific error widgets when available
- You SHOULD provide a retry button for recoverable errors
- You SHOULD use localized strings for error titles and descriptions
- You SHOULD show appropriate icons for different error types
- You SHOULD handle errors at the WidgetModel level, not in widgets

## Loading States

### Shimmer Pattern

Use shimmer widgets to indicate loading states:

```dart
Shimmer(
  loading: isLoading,
  child: contentWidget,
);
```

### Available Shimmer Widgets

- `Shimmer` — Generic shimmer wrapper
- `BaseShimmerWidget` — 3-column shimmer with gradient fade-out
- `CardShimmerWidget` — Configurable card shimmer
- `CardsListShimmerWidget` — ListView of card shimmers
- `TableLoaderWidget` — CircularProgressIndicator for tables
- Feature-specific shimmers (e.g., `my_partners_list_shimmer_widget.dart`)

### Loading State Management

Use `UnionState<T>` for states with loading/content/error variants:

```dart
// In WidgetModel
final UnionStateListenable<MyData> state = UnionStateNotifier<MyData>();

Future<void> loadData() async {
  state.value = UnionState.loading();
  
  try {
    final result = await repository.fetchData();
    result.when(
      ok: (data) => state.value = UnionState.content(data),
      failed: (failure) => state.value = UnionState.failed(failure),
    );
  } catch (e, s) {
    logWriter.exception(e, s);
    state.value = UnionState.failed(ApiFailure(original: e, trace: s));
  }
}
```

### UnionState Types

```dart
sealed class UnionState<T> {
  factory UnionState.content(T data) = Content<T>;
  factory UnionState.loading() = Loading;
  factory UnionState.failed(Failure failure) = Failed<T>;
}
```

### Building with UnionState

```dart
UnionStateListenableBuilder<MyData>(
  listenable: wm.state,
  loading: () => Shimmer(child: contentWidget, loading: true),
  content: (data) => buildContent(data),
  failed: (failure) => BaseErrorWidget(
    title: l10n.couldNotLoad,
    description: l10n.couldNotLoadMessage,
    onRetryPressed: wm.loadData,
  ),
);
```

## Error Handling Best Practices

- You SHOULD use `Result<T, F>` for operations that can fail
- You SHOULD use `RequestOperation<T, Failure>` in repository interfaces
- You SHOULD handle errors in WidgetModel, not in screen widgets
- You SHOULD use `UnionState` for states with loading/content/error variants
- You SHOULD show shimmer widgets during loading states
- You SHOULD use feature-specific error widgets when available
- You SHOULD provide retry functionality for recoverable errors
- You SHOULD use SnackQueue for user-facing error notifications
- You SHOULD log all errors with `ILogWriter.exception()`
- You SHOULD handle specific `ApiFailure` codes with custom messages
- You SHOULD fall back to `super.onErrorHandle()` for unhandled errors
- You SHOULD use localized strings for all error messages

## Common Error Messages

Use localized strings from `app_ru.arb`:
- `noInternetConnection` — No network
- `timeoutError` — Request timeout
- `somethingWentWrong` — Generic error
- `couldNotLoad` — Load failure title
- `couldNotLoadMessage` — Load failure description
