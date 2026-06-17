import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rooster/l10n/app_flutter_i18n.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart' show AppColorScheme;
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart' show AppSizesScheme;
import 'package:rooster/uikit/text/app_text_scheme.dart' show AppTextScheme;
import 'package:rooster/uikit/themes/app_theme_data.dart';

/// Оборачивает [child] в [MaterialApp] с [AppThemeData.lightTheme], чтобы в дереве
/// были доступны расширения темы ([AppColorScheme], [AppTextScheme], [AppSizesScheme] и др.).
Widget wrapWithAppTheme(Widget child) {
  return MaterialApp(
    theme: AppThemeData.lightTheme,
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: [
      appFlutterI18nDelegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}
