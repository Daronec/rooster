// ignore_for_file: public_member_api_docs

import 'dart:ui';

/// Основной цвет текста (#000000). Совпадает с [AppLightPalette.gray900].
const Color appPaletteGray900 = Color(0xFF000000);

/// App light colors.
///
/// База: основной #4D9C0F, фон #FFFFFF, второстепенный фон #E4E6EA, контуры #8D8D8D, текст чёрный.
enum AppLightPalette {
  // Gray scale: gray100 — второстепенный фон; gray300/gray500 — контуры (#8D8D8D).
  gray100(Color(0xFFE4E6EA)),
  gray200(Color(0xFFDCDEE3)),
  gray300(Color(0xFF8D8D8D)),
  gray400(Color(0xFFD8DADE)),
  gray500(Color(0xFF8D8D8D)),
  gray600(Color(0xFF6E6E6E)),
  gray700(Color(0xFF4A4A4A)),
  gray900(appPaletteGray900),
  black(Color(0xFF000000)),

  // Primary (брендовый зелёный и светлый оттенок)
  primaryLight(Color(0xFFEEF6E5)),
  primaryNormal(Color(0xFF4D9C0F)),

  // Green / success
  green(Color(0xFF4D9C0F)),

  // Red / Danger
  red(Color(0xFFD10D1A)),

  // Warning
  warning(Color(0xFFF68700)),

  white(Color(0xFFFFFFFF));

  /// Цвет.
  final Color value;

  const AppLightPalette(this.value);
}
