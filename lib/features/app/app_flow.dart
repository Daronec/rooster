import 'dart:ui' show PlatformDispatcher;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/app/app.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/locale_mode/presentation/locale_provider.dart';
import 'package:rooster/features/navigation/app_desktop_router.dart';
import 'package:rooster/features/navigation/app_mobile_router.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/theme_mode/presentation/theme_mode_provider.dart';
import 'package:rooster/integration/deep_links/deep_links_coordinator.dart';
import 'package:rooster/integration/notifications/local_notifications_bootstrap.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Точка входа виджетного дерева: scope, роутер, тема.
class AppFlow extends StatelessWidget {
  /// Создаёт корневой flow.
  const AppFlow({required this.appScope, super.key});

  /// Корневой scope приложения.
  final IAppScope appScope;

  @override
  Widget build(BuildContext context) {
    final view = PlatformDispatcher.instance.views.first;
    final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
    final useDesktopRouter = logicalWidth > AppSizes.kMobileWidth;

    return MultiProvider(
      providers: [
        Provider<IAppScope>(create: (_) => appScope),
        ChangeNotifierProvider<AppRouter>(
          create: (_) {
            final router = useDesktopRouter
                ? AppDesktopRouter()
                : AppMobileRouter();
            LocalNotificationsBootstrap.initialize(
              plugin: appScope.localNotificationsPlugin,
              logger: appScope.logger,
              onOpenTask: (taskId) async {
                await router.push<void>(CreateTaskRoute(taskId: taskId));
              },
            ).ignore();
            return router;
          },
        ),
        ProxyProvider2<IAppScope, AppRouter, DeepLinksCoordinator>(
          update: (_, scope, router, coordinator) {
            final result =
                coordinator ??
                DeepLinksCoordinator(
                  appLinks: AppLinks(),
                  router: router,
                  logger: scope.logger,
                );
            result.initialize().ignore();
            return result;
          },
          dispose: (_, coordinator) {
            coordinator.dispose().ignore();
          },
        ),
      ],
      child: const ThemeModeProvider(
        child: LocaleProvider(
          child: App(),
        ),
      ),
    );
  }
}
