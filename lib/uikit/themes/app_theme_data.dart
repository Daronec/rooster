import 'package:flutter/material.dart';
import 'package:rooster/uikit/buttons/app_button_scheme.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:rooster/util/system_chrome_util.dart';

const _borderRadius = BorderRadius.all(Radius.circular(16));

/// Class of the app themes data.
abstract class AppThemeData {
  /// Light theme configuration.
  static final lightTheme = ThemeData(
    extensions: [_lightColorScheme, _textScheme, _buttonScheme, _sizesScheme],
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: _textScheme.t14.copyWith(color: _lightColorScheme.gray900),
      floatingLabelStyle: _textScheme.t14.copyWith(
        color: _lightColorScheme.black,
      ),
      hintStyle: _textScheme.t14.copyWith(color: _lightColorScheme.gray600),
      errorStyle: _textScheme.t12.copyWith(color: _lightColorScheme.red),
      errorMaxLines: 2,
      iconColor: _lightColorScheme.black,
      prefixIconColor: _lightColorScheme.black,
      suffixIconColor: _lightColorScheme.black,
      filled: true,
      fillColor: _lightColorScheme.white,
      focusColor: _lightColorScheme.white,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.red),
        borderRadius: _borderRadius,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.gray300),
        borderRadius: _borderRadius,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.red),
        borderRadius: _borderRadius,
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.gray300),
        borderRadius: _borderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.gray300),
        borderRadius: _borderRadius,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.gray300),
        borderRadius: _borderRadius,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // Use PredictiveBackPageTransitionsBuilder to get the predictive back route transition!
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashFactory: NoSplash.splashFactory,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: _lightColorScheme.green,
      primaryContainer: _lightColorScheme.primaryLight,
      onPrimary: _lightColorScheme.white,
      secondary: _lightColorScheme.gray100,
      onSecondary: _lightColorScheme.black,
      error: _lightColorScheme.red,
      onError: _lightColorScheme.white,
      surface: _lightColorScheme.white,
      onSurface: _lightColorScheme.black,
      // M3: иначе surfaceTint по умолчанию даёт серый оттенок белым [Material].
      surfaceTint: Colors.transparent,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightColorScheme.white,
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_lightColorScheme.green),
      visualDensity: VisualDensity.compact,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.white,
      elevation: AppSizes.double0,
      iconTheme: IconThemeData(color: _lightColorScheme.black),
      titleTextStyle: _textScheme.t16Medium.copyWith(
        color: _lightColorScheme.black,
      ),
      systemOverlayStyle: SystemChromeUtil.defaultOverlayStyle,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      // Фон нижней панели навигации — белый.
      backgroundColor: _lightColorScheme.white,
      selectedItemColor: _lightColorScheme.green,
      unselectedItemColor: _lightColorScheme.gray600,
      selectedLabelStyle: _textScheme.t14.copyWith(
        fontWeight: FontWeight.w300,
        height: 1.3,
      ),
      unselectedLabelStyle: _textScheme.t14.copyWith(
        fontWeight: FontWeight.w300,
        height: 1.3,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _lightColorScheme.gray900,
      contentTextStyle: TextStyle(color: _lightColorScheme.white),
    ),
    listTileTheme: ListTileThemeData(tileColor: _lightColorScheme.white),
    popupMenuTheme: PopupMenuThemeData(
      textStyle: _textScheme.t16.copyWith(height: 1.3),
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );

  static final _lightColorScheme = AppColorScheme.light();

  /// Текстовая схема: системный шрифт платформы, без загрузки из сети.
  static final _textScheme = AppTextScheme.base();
  static final _buttonScheme = AppButtonScheme.base(
    colorScheme: _lightColorScheme,
    textScheme: _textScheme,
  );
  static final _sizesScheme = AppSizesScheme.base();
}
