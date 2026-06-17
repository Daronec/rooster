import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_light_palette.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_color_scheme.tailor.dart';

/// Цветовая схема приложения.
///
/// Значения задаются в [AppLightPalette].
///
/// Пример:
///
/// ```dart
/// final colorScheme = AppColorScheme.of(context);
/// return Container(color: colorScheme.primaryNormal);
/// ```
@immutable
@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppColorScheme extends ThemeExtension<AppColorScheme>
    with _$AppColorSchemeTailorMixin {

  /// @nodoc
  const AppColorScheme({
    required this.white,
    required this.black,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray400,
    required this.gray500,
    required this.gray600,
    required this.gray700,
    required this.gray900,
    required this.primaryLight,
    required this.primaryNormal,
    required this.green,
    required this.red,
    required this.warning,
  });

  /// Светлая тема.
  AppColorScheme.light()
    : white = AppLightPalette.white.value,
      black = AppLightPalette.black.value,
      gray100 = AppLightPalette.gray100.value,
      gray200 = AppLightPalette.gray200.value,
      gray300 = AppLightPalette.gray300.value,
      gray400 = AppLightPalette.gray400.value,
      gray500 = AppLightPalette.gray500.value,
      gray600 = AppLightPalette.gray600.value,
      gray700 = AppLightPalette.gray700.value,
      gray900 = AppLightPalette.gray900.value,
      primaryLight = AppLightPalette.primaryLight.value,
      primaryNormal = AppLightPalette.primaryNormal.value,
      green = AppLightPalette.green.value,
      red = AppLightPalette.red.value,
      warning = AppLightPalette.warning.value;
  @override
  final Color white;

  @override
  final Color black;

  @override
  final Color gray100;

  @override
  final Color gray200;

  @override
  final Color gray300;

  @override
  final Color gray400;

  @override
  final Color gray500;

  @override
  final Color gray600;

  @override
  final Color gray700;

  @override
  final Color gray900;

  @override
  final Color primaryLight;

  @override
  final Color primaryNormal;

  @override
  final Color green;

  @override
  final Color red;

  @override
  final Color warning;

  /// Обратная совместимость: то же, что [gray100].
  @override
  Color get grayLight => gray100;

  /// Обратная совместимость: то же, что [gray500].
  @override
  Color get gray => gray500;

  /// Обратная совместимость: то же, что [gray700].
  @override
  Color get grayDark => gray700;

  /// Получить [AppColorScheme] из [BuildContext].
  static AppColorScheme of(BuildContext context) =>
      // ignore: avoid-non-null-assertion
      Theme.of(context).extension<AppColorScheme>()!;
}
