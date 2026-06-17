import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/create_plan_task_wm.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:union_state/union_state.dart';

/// Контент экрана создания задачи плана (desktop).
class CreatePlanTaskDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const CreatePlanTaskDesktopContent({required this.wm, super.key});

  /// Widget model экрана.
  final ICreatePlanTaskWM wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(PlanningStrings.createTask(context)),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.double24),
            child: _CreatePlanTaskDesktopForm(wm: wm),
          ),
        ),
      ),
    );
  }
}

/// Форма создания задачи плана (desktop).
class _CreatePlanTaskDesktopForm extends StatelessWidget {
  const _CreatePlanTaskDesktopForm({required this.wm});

  final ICreatePlanTaskWM wm;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    final colorScheme = AppColorScheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: wm.titleController,
          decoration: InputDecoration(
            labelText: PlanningStrings.taskTitleLabel(context),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        const Height(AppSizes.double20),
        Text(
          PlanningStrings.importanceLabel(context),
          style: textScheme.body.t14.copyWith(color: colorScheme.gray600),
        ),
        const Height(AppSizes.double8),
        ValueListenableBuilder<double>(
          valueListenable: wm.importanceListenable,
          builder: (context, importance, _) {
            return _ImportanceSlider(
              importance: importance,
              onChanged: wm.onImportanceChanged,
            );
          },
        ),
      ],
    );
  }
}

/// Слайдер важности задачи.
class _ImportanceSlider extends StatelessWidget {
  const _ImportanceSlider({
    required this.importance,
    required this.onChanged,
  });

  /// Текущее значение важности.
  final double importance;

  /// Колбэк изменения значения.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${importance.round()}',
          style: textScheme.body.t16,
        ),
        Slider(
          min: 1,
          max: 5,
          divisions: 4,
          value: importance,
          label: '${importance.round()}',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
