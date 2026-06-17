import 'package:flutter/material.dart';
import 'package:rooster/features/navigation/desktop_main_navigation_bridge.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/gen/resources/resources.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/images/vector_image_widget.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

final BorderRadius _kNavRadius = BorderRadius.circular(AppSizes.double12);

/// Боковая панель навигации десктопа (Task Manager).
class MainDesktopNavigationSidebar extends StatelessWidget {
  /// Создаёт панель навигации.
  const MainDesktopNavigationSidebar({required this.bridge, super.key});

  /// Мост переключения вкладок и вторичной навигации.
  final DesktopMainNavigationBridge bridge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final activeIndex = bridge.activeTabIndex;
    return SizedBox(
      width: AppSizes.double320,
      child: Material(
        color: colorScheme.white,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.white,
            border: Border(right: BorderSide(color: colorScheme.gray200)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SidebarHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.double24),
                  child: Column(
                    children: [
                      _DesktopNavItem(
                        iconAsset: AssetsIcons.check,
                        label: TasksStrings.mainNavTasks(context),
                        isActive: activeIndex == 0,
                        onTap: () => bridge.selectTab(0),
                      ),
                      const Height(AppSizes.double8),
                      _DesktopNavItem(
                        iconAsset: AssetsIcons.list,
                        label: TasksStrings.mainNavLists(context),
                        isActive: activeIndex == 1,
                        onTap: () => bridge.selectTab(1),
                      ),
                      const Height(AppSizes.double8),
                      _DesktopNavItem(
                        iconAsset: AssetsIcons.layers,
                        label: PlanningStrings.screenTitle(context),
                        isActive: activeIndex == 2,
                        onTap: () => bridge.selectTab(2),
                      ),
                      const Height(AppSizes.double8),
                      _DesktopNavItem(
                        iconAsset: AssetsIcons.lightbulb,
                        label: TasksStrings.mainNavDecisions(context),
                        isActive: activeIndex == 3,
                        onTap: () => bridge.selectTab(3),
                      ),
                      const Height(AppSizes.double8),
                      _DesktopNavItem(
                        iconAsset: AssetsIcons.shield,
                        label: TasksStrings.mainNavProfile(context),
                        isActive: activeIndex == 4,
                        onTap: () => bridge.selectTab(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textStyle = AppTextScheme.of(context);
    return SizedBox(
      height: AppSizes.double88,
      child: ColoredBox(
        color: colorScheme.primaryNormal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.double24),
          child: Row(
            children: [
              Text(
                'Rooster',
                style: textStyle.t20.copyWith(color: colorScheme.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  const _DesktopNavItem({
    required this.iconAsset,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final backgroundColor = isActive
        ? colorScheme.primaryLight
        : Colors.transparent;
    final textStyle = AppTextScheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kNavRadius,
        child: Container(
          height: AppSizes.double72,
          padding: AppSizes.edgeInsetsAll16,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: _kNavRadius,
          ),
          child: Row(
            children: [
              VectorImageWidget(
                asset: iconAsset,
                width: AppSizes.double32,
                height: AppSizes.double32,
                color: isActive
                    ? colorScheme.primaryNormal
                    : colorScheme.gray600,
              ),
              const Width(AppSizes.double24),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.display.t24.copyWith(
                      color: isActive
                          ? colorScheme.gray900
                          : colorScheme.gray600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
