import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/theme_mode/di/theme_mode_scope.dart';
import 'package:rooster/features/theme_mode/presentation/theme_mode_controller.dart';
import 'package:rooster/features/theme_mode/presentation/theme_mode_widget.dart';

/// {@template theme_listener.class}
/// Provides [ThemeModeController] to its descendants.
/// {@endtemplate}
class ThemeModeProvider extends StatelessWidget {
  /// {@macro theme_listener.class}
  const ThemeModeProvider({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Get the [ThemeModeController] from the [BuildContext].
  static ThemeModeController of(BuildContext context) =>
      Provider.of<ThemeModeController>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Provider<IThemeModeScope>(
      create: ThemeModeScope.create,
      dispose: (ctx, scope) => scope.dispose(),
      child: ThemeModeWidget(child: child),
    );
  }
}
