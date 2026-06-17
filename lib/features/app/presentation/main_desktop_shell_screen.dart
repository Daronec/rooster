import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/app/presentation/widgets/main_desktop_navigation_sidebar.dart';
import 'package:rooster/features/navigation/desktop_main_navigation_bridge.dart';
import 'package:rooster/features/navigation/desktop_shell_navigation_host.dart';

/// Оболочка десктопа: сайдбар + вложенный стек.
@RoutePage(name: 'MainDesktopShellRoute')
class MainDesktopShellScreen extends StatelessWidget implements AutoRouteWrapper {
  /// Создаёт оболочку.
  const MainDesktopShellScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider<DesktopMainNavigationBridge>(
      create: (_) => DesktopMainNavigationBridge(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bridge = context.watch<DesktopMainNavigationBridge>();
    return DesktopShellNavigationHost(
      bridge: bridge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: bridge,
            builder: (_, __) {
              return MainDesktopNavigationSidebar(bridge: bridge);
            },
          ),
          Expanded(
            child: AutoRouter(
              builder: (nestedStackContext, navigatorChild) {
                bridge.registerShellStack(nestedStackContext.router);
                return navigatorChild;
              },
            ),
          ),
        ],
      ),
    );
  }
}
