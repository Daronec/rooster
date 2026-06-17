import 'package:auto_route/auto_route.dart';
import 'package:rooster/app_routing/app_route_paths.dart';
import 'package:rooster/features/navigation/app_router.dart';

/// Роутер десктопа: оболочка с сайдбаром.
class AppDesktopRouter extends AppRouter {
  /// Создаёт роутер десктопа.
  AppDesktopRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: AppRoutePaths.root,
      page: RootAuthGateRoute.page,
      initial: true,
    ),
    AutoRoute(
      path: AppRoutePaths.authFlow,
      page: AuthFlowRoute.page,
      children: [
        AutoRoute(
          path: AppRoutePaths.auth,
          page: AuthRoute.page,
          initial: true,
        ),
        AutoRoute(
          path: AppRoutePaths.register,
          page: RegisterRoute.page,
        ),
      ],
    ),
    AutoRoute(
      page: MainDesktopShellRoute.page,
      children: [
        AutoRoute(
          page: MainFlowRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: TasksFlowRoute.page,
              initial: true,
              children: [
                AutoRoute(page: TasksRoute.page, initial: true),
                AutoRoute(page: CreateTaskRoute.page),
                AutoRoute(page: TaskDetailRoute.page),
              ],
            ),
            AutoRoute(
              page: TaskListsFlowRoute.page,
              children: [
                AutoRoute(page: TaskListsRoute.page, initial: true),
                AutoRoute(page: CreateTaskListRoute.page),
              ],
            ),
            AutoRoute(
              page: PlanningFlowRoute.page,
              children: [
                AutoRoute(page: PlanningRoute.page, initial: true),
                AutoRoute(page: CreateTaskRoute.page),
                AutoRoute(page: TaskDetailRoute.page),
              ],
            ),
            AutoRoute(
              path: AppRoutePaths.decisionFlow,
              page: DecisionFlowRoute.page,
              children: [
                AutoRoute(page: DecisionTodayRoute.page, initial: true),
                AutoRoute(page: DecisionBlockedRoute.page),
                AutoRoute(page: DecisionResourcesRoute.page),
                AutoRoute(page: TaskDetailRoute.page),
              ],
            ),
            AutoRoute(
              page: ProfileFlowRoute.page,
              children: [
                AutoRoute(page: ProfileRoute.page, initial: true),
              ],
            ),
            AutoRoute(
              page: SettingsFlowRoute.page,
              children: [
                AutoRoute(page: SettingsRoute.page, initial: true),
              ],
            ),
          ],
        ),
        AutoRoute(
          page: DevPanelFlowRoute.page,
          children: [
            AutoRoute(page: DevPanelRoute.page, initial: true),
          ],
        ),
      ],
    ),
  ];
}
