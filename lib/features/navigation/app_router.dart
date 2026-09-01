import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rooster/app_routing/app_route_paths.dart';
import 'package:rooster/features/ai/presentation/ai_chat_flow.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_screen.dart';
import 'package:rooster/features/app/presentation/main_desktop_shell_screen.dart';
import 'package:rooster/features/app/presentation/main_flow.dart';
import 'package:rooster/features/auth/presentation/auth_flow.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_screen.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_screen.dart';
import 'package:rooster/features/dev_panel/presentation/dev_panel_flow.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_screen.dart';
import 'package:rooster/features/planning/presentation/planning_flow.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/create_plan_screen.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/create_plan_task_screen.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_screen.dart';
import 'package:rooster/features/profile/presentation/profile_flow.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_screen.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_screen.dart';
import 'package:rooster/features/settings/presentation/settings_flow.dart';
import 'package:rooster/features/tasks/presentation/decision_flow.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/decision_blocked_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_screen.dart';
import 'package:rooster/features/tasks/presentation/task_lists_flow.dart';
import 'package:rooster/features/tasks/presentation/tasks_flow.dart';

part 'app_router.gr.dart';

/// Граф навигации (мобильная конфигурация по умолчанию).
@AutoRouterConfig(replaceInRouteName: 'Flow|Screen|Widget,Route')
class AppRouter extends RootStackRouter {
  /// Создаёт роутер.
  AppRouter({super.navigatorKey});

  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: TransitionsBuilders.slideLeft,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 150),
  );

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
      path: AppRoutePaths.mainFlow,
      page: MainFlowRoute.page,
      children: [
        AutoRoute(
          page: TasksFlowRoute.page,
          initial: true,
          children: [
            AutoRoute(page: TasksRoute.page, initial: true),
            AutoRoute(page: CreateTaskRoute.page),
            AutoRoute(page: TaskDetailRoute.page),
            AutoRoute(page: TaskChangeHistoryRoute.page),
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
            AutoRoute(page: CreatePlanRoute.page),
            AutoRoute(page: CreatePlanTaskRoute.page),
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
          page: AiChatFlowRoute.page,
          children: [
            AutoRoute(page: AiChatRoute.page, initial: true),
          ],
        ),
      ],
    ),
    AutoRoute(
      path: '/settings',
      page: SettingsFlowRoute.page,
      children: [
        AutoRoute(page: SettingsRoute.page, initial: true),
      ],
    ),
    AutoRoute(
      path: AppRoutePaths.devPanelFlow,
      page: DevPanelFlowRoute.page,
      children: [
        AutoRoute(
          path: AppRoutePaths.devPanel,
          page: DevPanelRoute.page,
          initial: true,
        ),
      ],
    ),
  ];
}
