import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/locale_mode/presentation/locale_controller.dart';
import 'package:rooster/features/locale_mode/presentation/locale_wm.dart';

/// LocaleWidget provides [LocaleController] to its descendants.
class LocaleWidget extends ElementaryWidget<ILocaleWM> {
  /// Creates widget.
  const LocaleWidget({
    required this.child,
    super.key,
    WidgetModelFactory wmFactory = defaultLocaleWMFactory,
  }) : super(wmFactory);

  /// Child widget.
  final Widget child;

  @override
  Widget build(ILocaleWM wm) {
    return Provider<LocaleController>.value(value: wm, child: child);
  }
}
// End of file.
