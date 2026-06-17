import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';

/// {@template system_chrome_util.class}
/// Utility class for interacting with [SystemChrome].
/// {@endtemplate}
class SystemChromeUtil {
  /// Default app orientation mode.
  static const List<DeviceOrientation> appDefaultOrientation = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  /// Default app system UI mode.
  static const SystemUiMode appDefaultSystemUIMode = SystemUiMode.edgeToEdge;

  /// Lock app in portrait mode.
  static Future<void> lockDeviceRotation() async {
    await SystemChrome.setPreferredOrientations(appDefaultOrientation);
  }

  /// Unlock app landscape mode.
  static Future<void> unlockDeviceRotation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Enables [SystemUiMode.immersive] system UI mode.
  static Future<void> enableSeamlessUI() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  /// Enables [appDefaultSystemUIMode].
  static Future<void> disableSeamlessUI() async {
    await SystemChrome.setEnabledSystemUIMode(appDefaultSystemUIMode);
  }

  /// Стиль оверлеев с белыми иконками в статус-баре (для темы и [AnnotatedRegion]).
  static SystemUiOverlayStyle get defaultOverlayStyle {
    final colorScheme = AppColorScheme.light();
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: colorScheme.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  /// Единый стиль системных оверлеев для приложения: прозрачный статус-бар,
  /// белые иконки в статус-баре, навигационная панель из темы.
  static void setDefaultSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(defaultOverlayStyle);
  }
}
