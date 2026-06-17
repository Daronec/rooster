import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/navigation/router_logging_observer.dart';
import 'package:rooster/features/locale_mode/presentation/locale_provider.dart';
import 'package:rooster/features/theme_mode/presentation/widgets/theme_mode_builder.dart';
import 'package:rooster/l10n/app_flutter_i18n.dart';
import 'package:rooster/uikit/themes/app_theme_data.dart';
import 'package:rooster/util/system_chrome_util.dart';

/// Корневой виджет: тема, локализация, роутер.
class App extends StatelessWidget {
  /// Создаёт приложение.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = context.read<AppRouter>();
    return ThemeModeBuilder(
      builder: (_, themeMode) {
        final localeListenable = LocaleProvider.of(context).locale;
        return ValueListenableBuilder<Locale>(
          valueListenable: localeListenable,
          builder: (builderContext, locale, __) {
            return MaterialApp.router(
              locale: locale,
              supportedLocales: const [
                Locale('ru'),
                Locale('en'),
              ],
              localizationsDelegates: [
                appFlutterI18nDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: appRouter.config(
                navigatorObservers: () => [RouterLoggingObserver()],
              ),
              debugShowCheckedModeBanner: false,
              title: 'Task Manager',
              theme: AppThemeData.lightTheme,
              themeMode: themeMode,

              /// For snack and dialogs. StatusBarPaddingScope убирает верхний inset и даёт topPadding для AppBar под статус-бар.
              builder: (builderContext, widget) {
                final underI18n = FlutterI18n.rootAppBuilder()(
                  builderContext,
                  widget,
                );
                final easyDialogsBuilder = FlutterEasyDialogs.builder();

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemChromeUtil.defaultOverlayStyle,
                  child: MediaQuery.withNoTextScaling(
                    child: SnackQueueProvider(
                      child: Overlay(
                        initialEntries: [
                          // ignore: avoid-undisposed-instances
                          OverlayEntry(
                            builder: (overlayContext) =>
                                easyDialogsBuilder(overlayContext, underI18n),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Scroll behavior without thumb.
class NoThumbScrollBehavior extends ScrollBehavior {

  /// Scroll behavior without thumb.
  const NoThumbScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    if (!kIsWeb) ...{
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.trackpad,
    },
  };
}
