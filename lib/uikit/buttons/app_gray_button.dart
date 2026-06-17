import 'package:flutter/material.dart';
import 'package:rooster/uikit/buttons/app_base_button.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/buttons/app_button_scheme.dart';

/// {@template app_secondary_button}
/// Вторичная кнопка приложения.
/// {@endtemplate}
class AppGrayButton extends StatelessWidget {
  /// {@macro app_secondary_button}
  const AppGrayButton({
    required this.child,
    this.subtitle,
    this.subtitleStyle,
    this.onPressed,
    this.state = ButtonState.active,
    this.size = AppButtonSize.large,
    this.style,
    super.key,
  });

  /// Состояние кнопки
  ///
  /// При состоянии, отличном от [ButtonState.active], не работает [onPressed].
  final ButtonState state;

  /// Размер кнопки.
  final AppButtonSize size;

  /// Колбек нажатия на кнопку.
  final VoidCallback? onPressed;

  /// Стиль кнопки.
  final ButtonStyle? style;

  /// Контент кнопки.
  final Widget child;

  /// Подзаголовок под основным [child].
  final Widget? subtitle;

  /// Стиль подзаголовка.
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final buttonScheme = context.appButtonScheme;
    final buttonStyle =
        style ??
        switch (size) {
          AppButtonSize.small => buttonScheme.graySmall,
          AppButtonSize.medium => buttonScheme.grayMedium,
          AppButtonSize.large => buttonScheme.grayLarge,
        };

    return AppBaseButton(
      state: state,
      onPressed: onPressed,
      style: buttonStyle,
      subtitle: subtitle,
      subtitleStyle: subtitleStyle,
      child: child,
    );
  }
}
