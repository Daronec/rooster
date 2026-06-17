import 'package:flutter/material.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/planning_plan_card.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Контент экрана планирования (desktop).
class PlanningDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const PlanningDesktopContent({required this.wm, super.key});

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    final colorScheme = AppColorScheme.of(context);
    return ValueListenableBuilder<List<PlanningPlanEntity>>(
      valueListenable: wm.plansListenable,
      builder: (context, plans, _) {
        return AppScaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.double24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        PlanningStrings.screenTitle(context),
                        style: textScheme.t24.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.gray900,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: wm.onCreatePlan,
                      icon: const Icon(Icons.add),
                      label: Text(PlanningStrings.createPlan(context)),
                    ),
                  ],
                ),
                const Height(AppSizes.double24),
                Expanded(
                  child: plans.isEmpty
                      ? const _PlanningDesktopEmpty()
                      : ListView.separated(
                          itemCount: plans.length,
                          separatorBuilder: (_, __) =>
                              const Height(AppSizes.double12),
                          itemBuilder: (context, index) {
                            return PlanningPlanCard(plan: plans[index], wm: wm);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanningDesktopEmpty extends StatelessWidget {
  const _PlanningDesktopEmpty();

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    final colorScheme = AppColorScheme.of(context);
    return Center(
      child: Text(
        PlanningStrings.emptyPlans(context),
        textAlign: TextAlign.center,
        style: textScheme.t16.copyWith(color: colorScheme.gray600),
      ),
    );
  }
}
