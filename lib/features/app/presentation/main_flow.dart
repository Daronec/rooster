import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/navigation/desktop_shell_navigation_host.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';

const Duration _kMainTabsSwitchDuration = Duration(milliseconds: 280);

const Curve _kMainTabsSwitchCurve = Curves.easeOutCubic;

Widget _mainFlowTabsSlideTransition(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  final tabsRouter = AutoTabsRouter.of(context);
  final activeTabIndex = tabsRouter.activeIndex;
  final previousTabIndex = tabsRouter.previousIndex;

  final movingForward =
      previousTabIndex == null || activeTabIndex > previousTabIndex;
  final isLtr = Directionality.of(context) == TextDirection.ltr;
  final horizontalSign = (movingForward == isLtr) ? 1.0 : -1.0;

  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(horizontalSign, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

/// Главный экран: вкладки «Задачи», «Списки», «Решения», «Профиль».
@RoutePage(name: 'MainFlowRoute')
class MainFlow extends StatelessWidget {
  /// Создаёт flow.
  const MainFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = context.isDesktop
        ? const [
            TasksFlowRoute(),
            TaskListsFlowRoute(),
            PlanningFlowRoute(),
            DecisionFlowRoute(),
            ProfileFlowRoute(),
            SettingsFlowRoute(),
          ]
        : const [
            TasksFlowRoute(),
            TaskListsFlowRoute(),
            PlanningFlowRoute(),
            DecisionFlowRoute(),
            ProfileFlowRoute(),
            AiChatFlowRoute(),
          ];
    return AutoTabsRouter(
      routes: routes,
      duration: _kMainTabsSwitchDuration,
      curve: _kMainTabsSwitchCurve,
      transitionBuilder: _mainFlowTabsSlideTransition,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        if (context.isDesktop) {
          final shellBridge = DesktopShellNavigationHost.maybeOf(context);
          if (shellBridge != null) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              shellBridge.registerTabsRouter(tabsRouter);
            });
          }
          return child;
        }

        final colorScheme = AppColorScheme.of(context);
        return Scaffold(
          body: child,
          backgroundColor: colorScheme.white,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              final currentIndex = tabsRouter.activeIndex;
              if (index == currentIndex) {
                final currentTabName =
                    tabsRouter.stack[currentIndex].routeData.name;
                tabsRouter
                    .innerRouterOf<StackRouter>(currentTabName)
                    ?.popUntilRoot();
                return;
              }
              tabsRouter.setActiveIndex(index);
              final nextTabName = tabsRouter.stack[index].routeData.name;
              tabsRouter
                  .innerRouterOf<StackRouter>(nextTabName)
                  ?.popUntilRoot();
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.task_alt),
                label: TasksStrings.mainNavTasks(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.list),
                label: TasksStrings.mainNavLists(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.event_note_outlined),
                label: PlanningStrings.mainNavPlan(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.lightbulb_outline),
                label: TasksStrings.mainNavDecisions(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: TasksStrings.mainNavProfile(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.psychology_outlined),
                label: TasksStrings.mainNavAiChat(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
