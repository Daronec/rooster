import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for the builder callback used by [DuoListenableBuilder].
typedef DuoListenableWidgetBuilder<F, S> =
    Widget Function(BuildContext context, F first, S second, Widget? child);

/// Билдер двух состояний [ValueListenable].
class DuoListenableBuilder<F, S> extends StatefulWidget {
  /// Creates a [DuoListenableBuilder] widget with three listenables of types [F] and [S].
  const DuoListenableBuilder({
    required this.firstListenable,
    required this.secondListenable,
    required this.builder,
    this.child,
    super.key,
  });

  /// The [ValueListenable] to which this widget is listening.
  final ValueListenable<F> firstListenable;

  /// The [ValueListenable] to which this widget is listening.
  final ValueListenable<S> secondListenable;

  /// A [ValueWidgetBuilder] which builds a widget depending on the
  /// [firstListenable] and [secondListenable] value.
  ///
  /// Must not be null.
  // ignore: prefer-correct-callback-field-name
  final DuoListenableWidgetBuilder<F, S> builder;

  /// An independent widget which is passed back to the [builder].
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _DuoListenableBuilderState<F, S>();
}

class _DuoListenableBuilderState<F, S>
    extends State<DuoListenableBuilder<F, S>> {
  late F _firstValue;
  late S _secondValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.firstListenable.value;
    widget.firstListenable.addListener(_firstChanged);
    _secondValue = widget.secondListenable.value;
    widget.secondListenable.addListener(_secondChanged);
  }

  @override
  void didUpdateWidget(DuoListenableBuilder<F, S> oldWidget) {
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
  }

  @override
  void dispose() {
    widget.firstListenable.removeListener(_firstChanged);
    widget.secondListenable.removeListener(_secondChanged);
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

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _firstValue, _secondValue, widget.child);
  }
}
