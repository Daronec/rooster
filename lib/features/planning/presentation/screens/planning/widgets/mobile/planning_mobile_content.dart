import 'package:flutter/material.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/planning_plan_card.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Контент экрана планирования (mobile).
class PlanningMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const PlanningMobileContent({required this.wm, super.key});

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return ValueListenableBuilder<List<PlanningPlanEntity>>(
      valueListenable: wm.plansListenable,
      builder: (context, plans, _) {
        return AppScaffold(
          appBar: DefaultAppBar(
            title: Text(PlanningStrings.screenTitle(context)),
            withBackButton: false,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: wm.onCreatePlan,
            child: Icon(Icons.add, color: colorScheme.primaryNormal),
          ),
          body: Padding(
            padding: AppSizes.edgeInsetsAll16,
            child: plans.isEmpty
                ? const _PlanningMobileEmpty()
                : ListView.separated(
                    itemCount: plans.length,
                    separatorBuilder: (_, __) =>
                        const Height(AppSizes.double12),
                    itemBuilder: (context, index) {
                      return PlanningPlanCard(plan: plans[index], wm: wm);
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _PlanningMobileEmpty extends StatelessWidget {
  const _PlanningMobileEmpty();

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
