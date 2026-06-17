import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';

/// {@template app_scaffold}
/// Дефолтный [Scaffold].
/// {@endtemplate}
class AppScaffold extends StatelessWidget {
  /// {@macro app_scaffold}
  const AppScaffold({
    this.backgroundColor,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.safeAreaTop = false,
    super.key,
  });

  /// [AppBar] для [Scaffold].
  final PreferredSizeWidget? appBar;

  /// Контент.
  final Widget? body;

  /// Кнопка действия.
  final Widget? floatingActionButton;

  /// Позиция кнопки действия.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Нижняя навигационная панель.
  final Widget? bottomNavigationBar;

  /// Флаг изменения размера при появлении клавиатуры.
  final bool? resizeToAvoidBottomInset;

  /// Extend body behind app bar.
  final bool extendBodyBehindAppBar;

  /// Цвет фона.
  final Color? backgroundColor;

  /// SafeArea.
  final bool safeAreaTop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor ?? colorScheme.gray100,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: body,
    );
  }
}
