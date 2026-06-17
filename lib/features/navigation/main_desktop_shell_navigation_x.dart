import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/navigation/app_router.dart' show MainDesktopShellRoute;
import 'package:rooster/features/navigation/desktop_shell_navigation_host.dart';

/// Навигация с сохранением боковой панели на десктопе.
extension MainDesktopShellNavigationX on BuildContext {
  /// Открывает маршрут в стеке [MainDesktopShellRoute], если оболочка активна;
  /// иначе — в корне ([StackRouter.root]).
  Future<T?> pushInsideMainDesktopShell<T extends Object?>(
    PageRouteInfo route,
  ) async {
    final bridge = DesktopShellNavigationHost.maybeOf(this);
    if (bridge != null) {
      return bridge.pushSecondary<T>(route);
    }
    return router.root.push<T>(route);
  }
}
