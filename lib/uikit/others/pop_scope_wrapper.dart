import 'package:flutter/widgets.dart';
import 'package:rooster/util/async/safe_unawaited.dart';

/// Whether screen should pop callback.
typedef ShouldPopCallback = Future<bool> Function();

/// Navigation callback.
typedef PopCallback<T> = void Function(BuildContext context, [T? result]);

/// Pop scope wrapper.
///
/// Common wrapper for blocking pop functinality.
class PopScopeWrapper<T extends Object?> extends StatefulWidget {
  /// [PopScopeWrapper] constructor.
  const PopScopeWrapper({
    required this.child,
    required this.shouldPop,
    super.key,
    this.popCallback,
  });

  /// Child widget, which would be rendered below the wrapper.
  final Widget child;

  /// Should pop callback.
  ///
  /// Decides whether screen will be closed.
  // ignore: prefer-correct-callback-field-name
  final ShouldPopCallback shouldPop;

  /// Сallback for navigation return.
  // ignore: prefer-correct-callback-field-name
  final PopCallback<T>? popCallback;

  @override
  State<PopScopeWrapper<T>> createState() => _PopScopeWrapperState<T>();
}

class _PopScopeWrapperState<T> extends State<PopScopeWrapper<T>> {
  Future<void> _shouldPop(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }

    final shouldPop = await widget.shouldPop();

    if (shouldPop && mounted) {
      final res = result is T? ? result : null;

      (widget.popCallback ?? Navigator.pop)(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // The result argument contains the pop result.
      onPopInvokedWithResult: (didPop, result) =>
          safeUnawaited(_shouldPop(didPop, result)),
      child: widget.child,
    );
  }
}
