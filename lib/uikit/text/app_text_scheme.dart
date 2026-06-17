// ignore_for_file: avoid-non-null-assertion, prefer-correct-callback-field-name
import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_light_palette.dart'
    show appPaletteGray900;
import 'package:rooster/uikit/text/app_font_style_set.dart';

/// Схема текстовых стилей приложения.
///
/// Содержит два набора стилей с одинаковой матрицей размеров (10, 12, 14, 16, 20, 24, 32, 56)
/// и начертаний (regular, medium, bold). Шрифт не задаётся — используется системный по умолчанию.
/// - [body] — основной текст;
/// - [display] — заголовки и акценты (те же размеры, отдельный набор для анимаций/lerp).
///
/// Обратная совместимость: [t10]…[t24Bold] дублируют [body], [t24Oswald] и [t32] — [display].
class AppTextScheme extends ThemeExtension<AppTextScheme> {
  /// Создаёт схему с наборами стилей [body] и [display].
  const AppTextScheme({required this.body, required this.display});

  /// Базовая схема: константные [TextStyle] без [TextStyle.fontFamily] (системный шрифт).
  AppTextScheme.base()
    : body = const AppFontStyleSet(
        t10: _bodyT10,
        t10Medium: _bodyT10Medium,
        t12: _bodyT12,
        t12Medium: _bodyT12Medium,
        t12Bold: _bodyT12Bold,
        t14: _bodyT14,
        t14Medium: _bodyT14Medium,
        t16: _bodyT16,
        t16Medium: _bodyT16Medium,
        t16Bold: _bodyT16Bold,
        t20: _bodyT20,
        t20Medium: _bodyT20Medium,
        t20Bold: _bodyT20Bold,
        t24: _bodyT24,
        t24Medium: _bodyT24Medium,
        t24Bold: _bodyT24Bold,
        t32: _bodyT32,
        t32Medium: _bodyT32Medium,
        t32Bold: _bodyT32Bold,
        t56: _bodyT56,
        t56Medium: _bodyT56Medium,
        t56Bold: _bodyT56Bold,
      ),
      display = const AppFontStyleSet(
        t10: _displayT10,
        t10Medium: _displayT10Medium,
        t12: _displayT12,
        t12Medium: _displayT12Medium,
        t12Bold: _displayT12Bold,
        t14: _displayT14,
        t14Medium: _displayT14Medium,
        t16: _displayT16,
        t16Medium: _displayT16Medium,
        t16Bold: _displayT16Bold,
        t20: _displayT20,
        t20Medium: _displayT20Medium,
        t20Bold: _displayT20Bold,
        t24: _displayT24,
        t24Medium: _displayT24Medium,
        t24Bold: _displayT24Bold,
        t32: _displayT32,
        t32Medium: _displayT32Medium,
        t32Bold: _displayT32Bold,
        t56: _displayT56,
        t56Medium: _displayT56Medium,
        t56Bold: _displayT56Bold,
      );

  /// Стили основного текста для всех размеров и начертаний.
  final AppFontStyleSet body;

  /// Стили акцентного текста (заголовки) для всех размеров и начертаний.
  final AppFontStyleSet display;

  /// Обратная совместимость: основной текст 10.
  TextStyle get t10 => body.t10;

  /// Обратная совместимость: [body], 10 medium.
  TextStyle get t10Medium => body.t10Medium;

  /// Обратная совместимость: [body], 12.
  TextStyle get t12 => body.t12;

  /// Обратная совместимость: [body], 12 medium.
  TextStyle get t12Medium => body.t12Medium;

  /// Обратная совместимость: [body], 12 bold.
  TextStyle get t12Bold => body.t12Bold;

  /// Обратная совместимость: [body], 14.
  TextStyle get t14 => body.t14;

  /// Обратная совместимость: [body], 14 medium.
  TextStyle get t14Medium => body.t14Medium;

  /// Обратная совместимость: [body], 16.
  TextStyle get t16 => body.t16;

  /// Обратная совместимость: [body], 16 medium.
  TextStyle get t16Medium => body.t16Medium;

  /// Обратная совместимость: [body], 16 bold.
  TextStyle get t16Bold => body.t16Bold;

  /// Обратная совместимость: [body], 20.
  TextStyle get t20 => body.t20;

  /// Обратная совместимость: [body], 20 medium.
  TextStyle get t20Medium => body.t20Medium;

  /// Обратная совместимость: [body], 20 bold.
  TextStyle get t20Bold => body.t20Bold;

  /// Обратная совместимость: [body], 24.
  TextStyle get t24 => body.t24;

  /// Обратная совместимость: [body], 24 medium.
  TextStyle get t24Medium => body.t24Medium;

  /// Обратная совместимость: [body], 24 bold.
  TextStyle get t24Bold => body.t24Bold;

  /// Обратная совместимость: [body], 56.
  TextStyle get t56 => body.t56;

  /// Обратная совместимость: [body], 56 medium.
  TextStyle get t56Medium => body.t56Medium;

  /// Обратная совместимость: [body], 56 bold.
  TextStyle get t56Bold => body.t56Bold;

  /// Обратная совместимость: [display], 24 bold.
  TextStyle get t24Oswald => display.t24Bold;

  /// Обратная совместимость: [display], 32 regular.
  TextStyle get t32 => display.t32;

  static const _bodyT10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 12 / 10,
    color: appPaletteGray900,
  );
  static const _bodyT10Medium = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 12 / 10,
    color: appPaletteGray900,
  );
  static const _bodyT12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: appPaletteGray900,
  );
  static const _bodyT12Medium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: appPaletteGray900,
  );
  static const _bodyT12Bold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    color: appPaletteGray900,
  );
  static const _bodyT14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: appPaletteGray900,
  );
  static const _bodyT14Medium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: appPaletteGray900,
  );
  static const _bodyT16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: appPaletteGray900,
  );
  static const _bodyT16Medium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: appPaletteGray900,
  );
  static const _bodyT16Bold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    color: appPaletteGray900,
  );
  static const _bodyT20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 28 / 20,
    color: appPaletteGray900,
  );
  static const _bodyT20Medium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    color: appPaletteGray900,
  );
  static const _bodyT20Bold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: appPaletteGray900,
  );
  static const _bodyT24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24,
    color: appPaletteGray900,
  );
  static const _bodyT24Medium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 32 / 24,
    color: appPaletteGray900,
  );
  static const _bodyT24Bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: appPaletteGray900,
  );
  static const _bodyT32 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    color: appPaletteGray900,
  );
  static const _bodyT32Medium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 40 / 32,
    color: appPaletteGray900,
  );
  static const _bodyT32Bold = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: appPaletteGray900,
  );
  static const _bodyT56 = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w400,
    height: 70 / 56,
    color: appPaletteGray900,
  );
  static const _bodyT56Medium = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w500,
    height: 70 / 56,
    color: appPaletteGray900,
  );
  static const _bodyT56Bold = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 70 / 56,
    color: appPaletteGray900,
  );

  static const _displayT10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 12 / 10,
    color: appPaletteGray900,
  );
  static const _displayT10Medium = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 12 / 10,
    color: appPaletteGray900,
  );
  static const _displayT12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: appPaletteGray900,
  );
  static const _displayT12Medium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: appPaletteGray900,
  );
  static const _displayT12Bold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    color: appPaletteGray900,
  );
  static const _displayT14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: appPaletteGray900,
  );
  static const _displayT14Medium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: appPaletteGray900,
  );
  static const _displayT16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: appPaletteGray900,
  );
  static const _displayT16Medium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: appPaletteGray900,
  );
  static const _displayT16Bold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    color: appPaletteGray900,
  );
  static const _displayT20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 28 / 20,
    color: appPaletteGray900,
  );
  static const _displayT20Medium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    color: appPaletteGray900,
  );
  static const _displayT20Bold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: appPaletteGray900,
  );
  static const _displayT24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24,
    color: appPaletteGray900,
  );
  static const _displayT24Medium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 32 / 24,
    color: appPaletteGray900,
  );
  static const _displayT24Bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: appPaletteGray900,
  );
  static const _displayT32 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    color: appPaletteGray900,
  );
  static const _displayT32Medium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 40 / 32,
    color: appPaletteGray900,
  );
  static const _displayT32Bold = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: appPaletteGray900,
  );
  static const _displayT56 = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w400,
    height: 70 / 56,
    color: appPaletteGray900,
  );
  static const _displayT56Medium = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w500,
    height: 70 / 56,
    color: appPaletteGray900,
  );
  static const _displayT56Bold = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 70 / 56,
    color: appPaletteGray900,
  );

  @override
  AppTextScheme copyWith({AppFontStyleSet? body, AppFontStyleSet? display}) {
    return AppTextScheme(
      body: body ?? this.body,
      display: display ?? this.display,
    );
  }

  @override
  AppTextScheme lerp(covariant ThemeExtension<AppTextScheme>? other, double t) {
    if (other is! AppTextScheme) return this;
    return AppTextScheme(
      body: AppFontStyleSet.lerp(body, other.body, t),
      display: AppFontStyleSet.lerp(display, other.display, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppTextScheme &&
            body == other.body &&
            display == other.display);
  }

  @override
  int get hashCode => Object.hash(body, display);

  /// Получить [AppTextScheme] из [BuildContext].
  static AppTextScheme of(BuildContext context) =>
      Theme.of(context).extension<AppTextScheme>()!;
}

/// Доступ к [AppTextScheme] из [BuildContext] темы.
extension AppTextSchemeBuildContext on BuildContext {
  /// Возвращает [AppTextScheme] из темы текущего [BuildContext].
  AppTextScheme get appTextScheme => Theme.of(this).extension<AppTextScheme>()!;
}
