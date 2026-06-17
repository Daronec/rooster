import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';

/// Сегмент стека для [StackRouter.replaceAll]: основной UI с открытым экраном задач
/// (вкладка «Задачи» и [TasksRoute]).
List<PageRouteInfo<dynamic>> rootMainAppStack(BuildContext context) {
  return context.isDesktop
      ? [
          const MainDesktopShellRoute(
            children: [
              MainFlowRoute(
                children: [
                  TasksFlowRoute(
                    children: [TasksRoute()],
                  ),
                ],
              ),
            ],
          ),
        ]
      : [
          const MainFlowRoute(
            children: [
              TasksFlowRoute(
                children: [TasksRoute()],
              ),
            ],
          ),
        ];
}

/// Сегмент стека: основной UI с открытой вкладкой «Профиль» ([ProfileRoute]).
List<PageRouteInfo<dynamic>> rootMainAppStackOpenProfile(BuildContext context) {
  return rootMainAppStackOpenProfileRoutes(isDesktop: context.isDesktop);
}

/// То же, что [rootMainAppStackOpenProfile], без [BuildContext] (например после [addPostFrameCallback]).
List<PageRouteInfo<dynamic>> rootMainAppStackOpenProfileRoutes({
  required bool isDesktop,
}) {
  return isDesktop
      ? [
          const MainDesktopShellRoute(
            children: [
              MainFlowRoute(
                children: [
                  ProfileFlowRoute(
                    children: [ProfileRoute()],
                  ),
                ],
              ),
            ],
          ),
        ]
      : [
          const MainFlowRoute(
            children: [
              ProfileFlowRoute(
                children: [ProfileRoute()],
              ),
            ],
          ),
        ];
}
