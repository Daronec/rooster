import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/create_plan_wm.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:union_state/union_state.dart';

/// Контент экрана создания плана (mobile).
///
/// Кнопки «Сохранить» и «Отмена» находятся только в AppBar.
class CreatePlanMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const CreatePlanMobileContent({required this.wm, super.key});

  /// Widget model экрана.
  final ICreatePlanWM wm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Перехватываем системную кнопку «Назад» — делегируем в WM,
      // чтобы показать диалог подтверждения если поля заполнены.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          wm.onCancel();
        }
      },
      child: AppScaffold(
        appBar: DefaultAppBar(
          title: Text(PlanningStrings.createPlan(context)),
          // Кнопка «Назад» в AppBar делегируется в WM —
          // там показывается диалог подтверждения если поля заполнены.
          onBackButtonTap: wm.onCancel,
          actions: [
            ValueListenableBuilder<UnionState<void>>(
              valueListenable: wm.saveState,
              builder: (context, saveState, _) {
                final isLoading = saveState is UnionStateLoading<void>;
                return TextButton(
                  onPressed: isLoading ? null : wm.onSave,
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: AppSizes.double16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(PlanningStrings.save(context)),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppSizes.edgeInsetsAll16,
          child: _CreatePlanForm(wm: wm),
        ),
      ),
    );
  }
}

/// Форма создания плана (mobile).
class _CreatePlanForm extends StatelessWidget {
  const _CreatePlanForm({required this.wm});

  final ICreatePlanWM wm;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    final colorScheme = AppColorScheme.of(context);
    final localizations = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: wm.titleController,
          decoration: InputDecoration(
            labelText: PlanningStrings.planTitleLabel(context),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        const Height(AppSizes.double12),
        TextField(
          controller: wm.goalController,
          decoration: InputDecoration(
            labelText: PlanningStrings.goalLabel(context),
          ),
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
        const Height(AppSizes.double20),
        Text(
          PlanningStrings.periodLabel(context),
          style: textScheme.body.t14.copyWith(color: colorScheme.gray600),
        ),
        const Height(AppSizes.double8),
        ValueListenableBuilder<DateTime>(
          valueListenable: wm.periodStartListenable,
          builder: (context, periodStart, _) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(PlanningStrings.startDateLabel(context)),
              subtitle: Text(localizations.formatMediumDate(periodStart)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: wm.onPickStartDate,
            );
          },
        ),
        ValueListenableBuilder<DateTime>(
          valueListenable: wm.periodEndListenable,
          builder: (context, periodEnd, _) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(PlanningStrings.endDateLabel(context)),
              subtitle: Text(localizations.formatMediumDate(periodEnd)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: wm.onPickEndDate,
            );
          },
        ),
      ],
    );
  }
}
