import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Вкладка «Решения»: под-flow «Сегодня» / «Заблокировано» / «Ресурсы».
@RoutePage(name: 'DecisionFlowRoute')
class DecisionFlow extends StatelessWidget {
  /// Создаёт flow.
  const DecisionFlow({super.key});

  static void _selectTab(
    BuildContext context,
    TabsRouter tabsRouter,
    int index,
  ) {
    FocusManager.instance.primaryFocus?.unfocus();
    tabsRouter.setActiveIndex(index);
  }

  static String _titleForIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        return TasksDecisionStrings.todayTitle(context);
      case 1:
        return TasksDecisionStrings.blockedTitle(context);
      case 2:
        return TasksDecisionStrings.resourcesTitle(context);
      default:
        return TasksDecisionStrings.mainNavLabel(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        DecisionTodayRoute(),
        DecisionBlockedRoute(),
        DecisionResourcesRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final colorScheme = AppColorScheme.of(context);
        return ListenableBuilder(
          listenable: tabsRouter,
          builder: (context, _) {
            final isDesktopLayout = context.isDesktop;
            final titleText = _titleForIndex(context, tabsRouter.activeIndex);
            if (isDesktopLayout) {
              return AppScaffold(
                appBar: DefaultAppBar(
                  title: Text(
                    titleText,
                    style: AppTextStyle.t20Medium.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  withBackButton: false,
                ),
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NavigationRail(
                      backgroundColor: colorScheme.white,
                      selectedIndex: tabsRouter.activeIndex,
                      onDestinationSelected: (index) {
                        _selectTab(context, tabsRouter, index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        NavigationRailDestination(
                          icon: const Icon(Icons.today_outlined),
                          selectedIcon: const Icon(Icons.today),
                          label: Text(
                            TasksDecisionStrings.flowTabToday(context),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.block_outlined),
                          selectedIcon: const Icon(Icons.block),
                          label: Text(
                            TasksDecisionStrings.flowTabBlocked(context),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.inventory_2_outlined),
                          selectedIcon: const Icon(Icons.inventory_2),
                          label: Text(
                            TasksDecisionStrings.flowTabResources(context),
                          ),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colorScheme.gray200,
                    ),
                    Expanded(child: child),
                  ],
                ),
              );
            }
            return AppScaffold(
              appBar: DefaultAppBar(
                title: Text(
                  titleText,
                  style: AppTextStyle.t20Medium.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                withBackButton: false,
              ),
              body: child,
              bottomNavigationBar: NavigationBar(
                height: AppSizes.double72,
                backgroundColor: colorScheme.white,
                indicatorColor: colorScheme.primaryLight,
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: (index) {
                  _selectTab(context, tabsRouter, index);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.today_outlined),
                    selectedIcon: const Icon(Icons.today),
                    label: TasksDecisionStrings.flowTabToday(context),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.block_outlined),
                    selectedIcon: const Icon(Icons.block),
                    label: TasksDecisionStrings.flowTabBlocked(context),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.inventory_2_outlined),
                    selectedIcon: const Icon(Icons.inventory_2),
                    label: TasksDecisionStrings.flowTabResources(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
