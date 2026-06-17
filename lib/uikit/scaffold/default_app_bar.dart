import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// {@template default_app_bar}
/// Стандартный AppBar для приложения.
/// {@endtemplate}
class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro default_app_bar}
  const DefaultAppBar({
    this.title,
    this.actions,
    this.withBackButton = true,
    super.key,
    this.height,
    this.bottom,
    this.onBackButtonTap,
    this.backButton,
  });

  /// Custom app bar height.
  final double? height;

  /// Заголовок.
  final Widget? title;

  /// Заголовок.
  final Widget? backButton;

  /// Bottom widget attached to app bar.
  final PreferredSizeWidget? bottom;

  /// Whether to show back button.
  final bool withBackButton;

  /// [VoidCallback] for back button tap.
  final VoidCallback? onBackButtonTap;

  /// List of app bar actions. Displayed at the right corner of app.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;

    return AppBar(
      leadingWidth: AppSizes.double36,
      leading:
      withBackButton
          ? backButton ?? Center(
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackButtonTap,
        ),
      )
          : null,
      title: title,
      centerTitle: true,
      actions: actions,
      bottom: bottom,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? AppSizes.appBarHeight);
}
