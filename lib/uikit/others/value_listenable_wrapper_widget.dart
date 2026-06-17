import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Returns whether show button based on provided data or not.
typedef ConditionBuilder<T> = bool Function(T data);

/// ValueListenableBuilder for change visible widget.
class ValueListenableWrapperWidget<T> extends StatelessWidget {
  /// {@macro visibility_wrapper_widget.dart}
  const ValueListenableWrapperWidget({
    required this.child,
    required this.conditionBuilder,
    required this.valueListenable,
    super.key,
  });

  /// Child button widget.
  final Widget child;

  /// [ValueListenable] for listener value.
  final ValueListenable<T> valueListenable;

  /// Returns whether show button based on provided data or not.
  final ConditionBuilder<T> conditionBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (_, value, childWidget) =>
          conditionBuilder(value) ? child : const SizedBox(),
      child: child,
    );
  }
}
