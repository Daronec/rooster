import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/locale_mode/di/locale_scope.dart';
import 'package:rooster/features/locale_mode/presentation/locale_controller.dart';
import 'package:rooster/features/locale_mode/presentation/locale_widget.dart';

/// Provides [LocaleController] to its descendants.
class LocaleProvider extends StatelessWidget {
  /// Creates provider.
  const LocaleProvider({required this.child, super.key});

  /// Widget below this widget in the tree.
  final Widget child;

  /// Get [LocaleController] from the [BuildContext].
  static LocaleController of(BuildContext context) =>
      Provider.of<LocaleController>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Provider<ILocaleScope>(
      create: LocaleScope.create,
      dispose: (ctx, scope) => scope.dispose(),
      child: LocaleWidget(child: child),
    );
  }
}
// End of file.
