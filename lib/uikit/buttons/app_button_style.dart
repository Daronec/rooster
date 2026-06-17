// ignore_for_file: avoid-long-records, move-records-to-typedefs

import 'package:flutter/material.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// {@template app_button_style}
/// Стиль кнопки.
/// {@endtemplate}
class AppButtonStyle extends ButtonStyle {

  /// {@macro app_button_style}
  AppButtonStyle({
    required this.buttonColor,
    required this.buttonHoverColor,
    required this.buttonPressedColor,
    required this.buttonDisabledColor,
    required this.buttonFocusColor,
    required this.textColor,
    required this.textDisabledColor,
    required this.textFocusColor,
    required super.minimumSize,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    super.fixedSize,
    WidgetStateProperty<OutlinedBorder?>? shape,
    super.side,
    super.iconSize,
  }) : super(
         animationDuration: kThemeChangeDuration,
         enableFeedback: true,
         alignment: Alignment.center,
         splashFactory: NoSplash.splashFactory,
         elevation: WidgetStateProperty.all(0),
         shadowColor: WidgetStateProperty.all(Colors.transparent),
         textStyle: WidgetStateProperty.all(textStyle),
         padding: WidgetStateProperty.all(padding),
         shape:
             shape ??
             WidgetStateProperty.all(
               const RoundedRectangleBorder(
                 borderRadius: AppSizes.borderRadius16,
               ),
             ),
       );

  /// Создать стиль для основной (брендовой) кнопки.
  factory AppButtonStyle.primary({
    required AppColorScheme colorScheme,
    required AppTextScheme textScheme,
    required AppButtonSize size,
  }) {
    final (:padding, :textStyle, :buttonSize, :circularRadius) = _configureSize(
      textScheme: textScheme,
      size: size,
    );

    return AppButtonStyle(
      buttonColor: colorScheme.green,
      buttonHoverColor: colorScheme.green,
      buttonPressedColor:
          Color.alphaBlend(const Color(0x33000000), colorScheme.green),
      buttonDisabledColor: colorScheme.gray400,
      buttonFocusColor: colorScheme.green,
      textColor: colorScheme.white,
      textDisabledColor: colorScheme.gray700,
      textFocusColor: colorScheme.white,
      minimumSize: WidgetStateProperty.all(buttonSize),
      textStyle: textStyle,
      padding: padding,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
        ),
      ),
    );
  }

  /// Создать стиль для чёрной кнопки.
  factory AppButtonStyle.black({
    required AppColorScheme colorScheme,
    required AppTextScheme textScheme,
    required AppButtonSize size,
  }) {
    final (:padding, :textStyle, :buttonSize, :circularRadius) = _configureSize(
      textScheme: textScheme,
      size: size,
    );

    final side = size == AppButtonSize.small
        ? WidgetStateProperty.resolveWith<BorderSide>((states) {
            return states.contains(WidgetState.disabled)
                ? const BorderSide(color: _inactiveSmallBorderColor)
                : BorderSide.none;
          })
        : null;

    return AppButtonStyle(
      buttonColor: colorScheme.black,
      buttonHoverColor: colorScheme.black,
      buttonPressedColor: colorScheme.black,
      buttonDisabledColor: colorScheme.gray400,
      buttonFocusColor: colorScheme.black,
      textColor: colorScheme.white,
      textDisabledColor: colorScheme.gray700,
      textFocusColor: colorScheme.white,
      minimumSize: WidgetStateProperty.all(buttonSize),
      textStyle: textStyle,
      padding: padding,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
        ),
      ),
      side: side,
    );
  }

  /// Создать стиль для белой кнопки.
  factory AppButtonStyle.white({
    required AppColorScheme colorScheme,
    required AppTextScheme textScheme,
    required AppButtonSize size,
  }) {
    final (:padding, :textStyle, :buttonSize, :circularRadius) = _configureSize(
      textScheme: textScheme,
      size: size,
    );
    return AppButtonStyle(
      buttonColor: colorScheme.white,
      buttonHoverColor: colorScheme.white,
      buttonPressedColor: colorScheme.white,
      buttonDisabledColor: colorScheme.gray400,
      buttonFocusColor: colorScheme.white,
      textColor: colorScheme.black,
      textDisabledColor: colorScheme.white,
      textFocusColor: colorScheme.black,
      minimumSize: WidgetStateProperty.all(buttonSize),
      textStyle: textStyle,
      padding: padding,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
        ),
      ),
    );
  }

  /// Создать стиль для серой кнопки по умолчанию (отмена и вторичные действия).
  factory AppButtonStyle.gray({
    required AppColorScheme colorScheme,
    required AppTextScheme textScheme,
    required AppButtonSize size,
  }) {
    final (:padding, :textStyle, :buttonSize, :circularRadius) = _configureSize(
      textScheme: textScheme,
      size: size,
    );

    return AppButtonStyle(
      buttonColor: colorScheme.gray400,
      buttonHoverColor: colorScheme.gray300,
      buttonPressedColor: colorScheme.gray500,
      buttonDisabledColor: colorScheme.gray400,
      buttonFocusColor: colorScheme.gray400,
      textColor: colorScheme.gray900,
      textDisabledColor: colorScheme.gray700,
      textFocusColor: colorScheme.gray900,
      minimumSize: WidgetStateProperty.all(buttonSize),
      textStyle: textStyle,
      padding: padding,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
        ),
      ),
    );
  }
  /// Цвет кнопки в обычном состоянии.
  final Color buttonColor;

  /// Цвет кнопки при наведении.
  final Color buttonHoverColor;

  /// Цвет кнопки при нажатии.
  final Color buttonPressedColor;

  /// Цвет кнопки в отключенном состоянии.
  final Color buttonDisabledColor;

  /// Цвет кнопки при фокусе.
  final Color buttonFocusColor;

  /// Цвет текста в обычном состоянии.
  final Color textColor;

  /// Цвет текста в отключенном состоянии.
  final Color textDisabledColor;

  /// Цвет текста при фокусе.
  final Color textFocusColor;

  @override
  WidgetStateColor get backgroundColor => WidgetStateColor.resolveWith((state) {
    if (state.contains(WidgetState.disabled)) {
      return buttonDisabledColor;
    }

    return buttonColor;
  });

  @override
  WidgetStateColor get overlayColor => WidgetStateColor.resolveWith((state) {
    if (state.contains(WidgetState.pressed)) {
      return buttonPressedColor;
    } else if (state.contains(WidgetState.focused)) {
      return buttonFocusColor;
    } else if (state.contains(WidgetState.hovered)) {
      return buttonHoverColor;
    }

    return Colors.transparent;
  });

  @override
  WidgetStateColor get foregroundColor => WidgetStateColor.resolveWith((state) {
    if (state.contains(WidgetState.disabled)) {
      return textDisabledColor;
    } else if (state.contains(WidgetState.hovered)) {
      return textColor;
    } else if (state.contains(WidgetState.focused)) {
      return textFocusColor;
    }

    return textColor;
  });

  @override
  WidgetStateColor get iconColor => foregroundColor;

  /// Цвет бордера для неактивной кнопки small.
  static const Color _inactiveSmallBorderColor = Color(0xFFD4DAE3);

  static ({
    EdgeInsetsGeometry padding,
    TextStyle textStyle,
    Size buttonSize,
    double circularRadius,
  })
  _configureSize({
    required AppTextScheme textScheme,
    required AppButtonSize size,
  }) {
    return (
      padding: switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(
          vertical: AppSizes.double4,
          horizontal: AppSizes.double8,
        ),
        AppButtonSize.medium || AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: AppSizes.double32),
      },
      textStyle: switch (size) {
        AppButtonSize.large => textScheme.t16Bold,
        AppButtonSize.medium => textScheme.t16Bold,
        AppButtonSize.small => textScheme.t12Bold,
      }.copyWith(height: 1),
      buttonSize: switch (size) {
        AppButtonSize.small => const Size(0, AppSizes.double32),
        AppButtonSize.medium => const Size(0, AppSizes.double48),
        AppButtonSize.large => const Size(0, AppSizes.double64),
      },
      circularRadius: switch (size) {
        AppButtonSize.small => AppSizes.double16,
        AppButtonSize.medium => AppSizes.double24,
        AppButtonSize.large => AppSizes.double32,
      },
    );
  }
}
