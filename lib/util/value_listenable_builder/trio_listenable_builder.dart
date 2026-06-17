import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for the builder callback used by [TrioListenableBuilder].
typedef TrioListenableWidgetBuilder<F, S, T> =
    Widget Function(
      BuildContext context,
      F first,
      S second,
      T third,
      Widget? child,
    );

/// Билдер трёх состояний [ValueListenable].
class TrioListenableBuilder<F, S, T> extends StatefulWidget {
  /// Creates a [TrioListenableBuilder] widget with three listenables of types [F], [S] and [T].
  const TrioListenableBuilder({
    required this.firstListenable,
    required this.secondListenable,
    required this.thirdListenable,
    required this.builder,
    this.child,
    super.key,
  });

  /// The [ValueListenable] to which this widget is listening.
  final ValueListenable<F> firstListenable;

  /// The [ValueListenable] to which this widget is listening.
  final ValueListenable<S> secondListenable;

  /// The [ValueListenable] to which this widget is listening.
  final ValueListenable<T> thirdListenable;

  /// A [ValueWidgetBuilder] which builds a widget depending on the
  /// [firstListenable], [secondListenable] and [thirdListenable] value.
  ///
  /// Must not be null.
  // ignore: prefer-correct-callback-field-name
  final TrioListenableWidgetBuilder<F, S, T> builder;

  /// An independent widget which is passed back to the [builder].
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _TrioListenableBuilderState<F, S, T>();
}

class _TrioListenableBuilderState<F, S, T>
    extends State<TrioListenableBuilder<F, S, T>> {
  late F _firstValue;
  late S _secondValue;
  late T _thirdValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.firstListenable.value;
    widget.firstListenable.addListener(_firstChanged);
    _secondValue = widget.secondListenable.value;
    widget.secondListenable.addListener(_secondChanged);
    _thirdValue = widget.thirdListenable.value;
    widget.thirdListenable.addListener(_thirdChanged);
  }

  @override
  void didUpdateWidget(TrioListenableBuilder<F, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstListenable != widget.firstListenable) {
      oldWidget.firstListenable.removeListener(_firstChanged);
      _firstValue = widget.firstListenable.value;
      widget.firstListenable.addListener(_firstChanged);
    }
    if (oldWidget.secondListenable != widget.secondListenable) {
      oldWidget.secondListenable.removeListener(_secondChanged);
      _secondValue = widget.secondListenable.value;
      widget.secondListenable.addListener(_secondChanged);
    }
    if (oldWidget.thirdListenable != widget.thirdListenable) {
      oldWidget.thirdListenable.removeListener(_thirdChanged);
      _thirdValue = widget.thirdListenable.value;
      widget.thirdListenable.addListener(_thirdChanged);
    }
  }

  @override
  void dispose() {
    widget.firstListenable.removeListener(_firstChanged);
    widget.secondListenable.removeListener(_secondChanged);
    widget.thirdListenable.removeListener(_thirdChanged);
    super.dispose();
  }

  void _firstChanged() {
    setState(() {
      _firstValue = widget.firstListenable.value;
    });
  }

  void _secondChanged() {
    setState(() {
      _secondValue = widget.secondListenable.value;
    });
  }

  void _thirdChanged() {
    setState(() {
      _thirdValue = widget.thirdListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _firstValue,
      _secondValue,
      _thirdValue,
      widget.child,
    );
  }
}
