import 'package:flutter/foundation.dart';
import 'package:union_state/union_state.dart';

/// Extension for [ValueNotifier].
extension ValueNotifierX<T> on ValueNotifier<T> {
  /// Change value.
  // ignore: use_setters_to_change_properties
  void emit(T value) {
    this.value = value;
  }
}

/// Extension for [UnionState].
extension UnionStateX<T> on UnionState<T> {
  /// Check if state is content.
  bool get isContent => this is UnionStateContent<T>;

  /// Check if state is loading.
  bool get isLoading => this is UnionStateLoading<T>;

  /// Check if state is failure.
  bool get isFailure => this is UnionStateFailure<T>;

  /// Get data.
  // ignore: no-object-declaration
  Object? get exceptionOrNull {
    if (this is UnionStateFailure<T>) {
      return (this as UnionStateFailure<T>).exception;
    }

    return null;
  }
}

/// Page State.
typedef PageState = UnionState<void>;

/// Page State Listenable.
///
/// [PageStateListenable] is a [ValueListenable] for [UnionState<void>].
///
/// This listenable is used to listen the state of the some page.
typedef PageStateListenable = ValueListenable<PageState>;

/// Page State Notifier.
///
/// [PageStateNotifier] is a [ValueNotifier] for [UnionState<void>].
///
/// This notifier is used to manage the state of the somepage.
class PageStateNotifier extends ValueNotifier<PageState> {
  /// Creates a [ValueNotifier] with the specified [value].
  PageStateNotifier() : super(const UnionStateContent(null));

  /// Change value to content state.
  void content() {
    emit(const UnionStateContent(null));
  }

  /// Change value to loading state.
  void loading() {
    emit(const UnionStateLoading());
  }

  /// Change value to failure state.
  void failure({Object? exception}) {
    emit(UnionStateFailure(exception is Exception ? exception : null));
  }
}
