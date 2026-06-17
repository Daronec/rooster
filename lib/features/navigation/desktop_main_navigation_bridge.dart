import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/app/presentation/main_desktop_shell_screen.dart'
    show MainDesktopShellScreen;
import 'package:rooster/features/app/presentation/main_flow.dart' show MainFlow;
import 'package:rooster/features/navigation/app_router.dart';

/// Связка боковой панели десктопа с [TabsRouter] вкладок и стеком оболочки.
///
/// Регистрируется из [MainDesktopShellScreen] и [MainFlow] (вкладки).
class DesktopMainNavigationBridge extends ChangeNotifier {
  StackRouter? _shellStack;
  TabsRouter? _tabsRouter;

  /// Текущий индекс основной вкладки (0…5).
  int get activeTabIndex => _tabsRouter?.activeIndex ?? 0;

  /// Привязать стек маршрутов оболочки (дочерние экраны справа от сайдбара).
  void registerShellStack(StackRouter router) {
    if (_shellStack == router) {
      return;
    }
    _shellStack = router;
  }

  /// Привязать [TabsRouter] из [MainFlow] (десктоп без нижней панели).
  void registerTabsRouter(TabsRouter router) {
    if (_tabsRouter == router) {
      return;
    }
    _tabsRouter?.removeListener(_onTabsChanged);
    _tabsRouter = router;
    _tabsRouter?.addListener(_onTabsChanged);
    notifyListeners();
  }

  void _onTabsChanged() => notifyListeners();

  /// Переключить основную вкладку.
  ///
  /// Пересоздаёт [MainFlowRoute] с корнем выбранной вкладки, чтобы убрать
  /// вложенные detail/edit routes и случайно задублированные MainFlowRoute.
  void selectTab(int index) {
    final shellStack = _shellStack;
    if (shellStack != null) {
      shellStack.replaceAll([_mainFlowRouteForIndex(index)]).ignore();
      return;
    }

    final tabsRouter = _tabsRouter;
    if (tabsRouter == null) {
      return;
    }
    if (index < 0 || index >= tabsRouter.stack.length) {
      return;
    }
    tabsRouter.setActiveIndex(index);
    _resetTabStack(tabsRouter, index);
  }

  void _resetTabStack(TabsRouter tabsRouter, int index) {
    final tabName = tabsRouter.stack[index].routeData.name;
    tabsRouter.innerRouterOf<StackRouter>(tabName)?.popUntilRoot();
  }

  PageRouteInfo _mainFlowRouteForIndex(int index) {
    return MainFlowRoute(
      children: [
        switch (index) {
          1 => const TaskListsFlowRoute(children: [TaskListsRoute()]),
          2 => const PlanningFlowRoute(children: [PlanningRoute()]),
          3 => const DecisionFlowRoute(children: [DecisionTodayRoute()]),
          4 => const ProfileFlowRoute(children: [ProfileRoute()]),
          5 => const SettingsFlowRoute(children: [SettingsRoute()]),
          _ => const TasksFlowRoute(children: [TasksRoute()]),
        },
      ],
    );
  }

  /// Открыть маршрут поверх оболочки (настройки, формы и т.д.), сайдбар остаётся.
  Future<T?> pushSecondary<T extends Object?>(PageRouteInfo route) {
    final stack = _shellStack;
    if (stack == null) {
      return Future.value();
    }
    return stack.push<T>(route);
  }

  @override
  void dispose() {
    _tabsRouter?.removeListener(_onTabsChanged);
    super.dispose();
  }
}
