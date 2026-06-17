import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/navigation/desktop_shell_navigation_host.dart';
import 'package:rooster/features/navigation/main_desktop_shell_navigation_x.dart';
import 'package:rooster/util/async/safe_unawaited.dart';

/// Переходы с боковой панели десктопа.
abstract final class MainDesktopShellNavigation {
  /// Вкладка «Задачи».
  static void openTasks(BuildContext context) {
    DesktopShellNavigationHost.maybeOf(context)?.selectTab(0);
  }

  /// Вкладка «Списки».
  static void openLists(BuildContext context) {
    DesktopShellNavigationHost.maybeOf(context)?.selectTab(1);
  }

  /// Вкладка «Планирование».
  static void openPlanning(BuildContext context) {
    DesktopShellNavigationHost.maybeOf(context)?.selectTab(2);
  }

  /// Вкладка «Решения».
  static void openDecisions(BuildContext context) {
    DesktopShellNavigationHost.maybeOf(context)?.selectTab(3);
  }

  /// Вкладка «Профиль».
  static void openProfile(BuildContext context) {
    DesktopShellNavigationHost.maybeOf(context)?.selectTab(4);
  }

  /// Вкладка «Настройки» (нижняя зона — дублирует push).
  static void openSettingsTab(BuildContext context) {
    DesktopShellNavigationHost.maybeOf(context)?.selectTab(5);
  }

  /// Экран настроек (пятая вкладка).
  static void openSettings(BuildContext context) {
    openSettingsTab(context);
  }

  /// Dev-панель.
  static void openDevPanel(BuildContext context) {
    safeUnawaited(
      context.pushInsideMainDesktopShell(const DevPanelFlowRoute()),
    );
  }

  /// Произвольный маршрут в оболочке.
  static void openInShellOrRoot(BuildContext context, PageRouteInfo route) {
    safeUnawaited(context.pushInsideMainDesktopShell(route));
  }
}
