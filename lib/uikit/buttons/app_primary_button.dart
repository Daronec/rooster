import 'package:flutter/material.dart';
import 'package:rooster/uikit/buttons/app_base_button.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/buttons/app_button_scheme.dart';

/// {@template app_primary_button}
/// Основная кнопка приложения.
/// {@endtemplate}
class AppPrimaryButton extends StatelessWidget {
  /// {@macro app_primary_button}
  const AppPrimaryButton({
    required this.child,
    this.subtitle,
    this.subtitleStyle,
    this.onPressed,
    this.state = ButtonState.active,
    this.size = AppButtonSize.small,
    this.style,
    super.key,
  });

  /// Кнопка с иконкой и текстом.
  factory AppPrimaryButton.icon({
    required Widget label,
    required Widget icon,
    Widget? subtitle,
    TextStyle? subtitleStyle,
    VoidCallback? onPressed,
    ButtonState state = ButtonState.active,
    AppButtonSize size = AppButtonSize.small,
    ButtonStyle? style,
    Key? key,
    double iconGap = 8,
  }) {
    return AppPrimaryButton(
      key: key,
      subtitle: subtitle,
      subtitleStyle: subtitleStyle,
      onPressed: onPressed,
      state: state,
      size: size,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: iconGap),
          Flexible(child: label),
        ],
      ),
    );
  }

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

  /// Подзаголовок под основным [child] (см. [AppBaseButton.subtitle]).
  final Widget? subtitle;

  /// Стиль подзаголовка (см. [AppBaseButton.subtitleStyle]).
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final buttonScheme = context.appButtonScheme;
    final buttonStyle =
        style ??
        switch (size) {
          AppButtonSize.small => buttonScheme.primarySmall,
          AppButtonSize.medium => buttonScheme.primaryMedium,
          AppButtonSize.large => buttonScheme.primaryLarge,
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
