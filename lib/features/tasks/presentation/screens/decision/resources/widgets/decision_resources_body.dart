import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_snapshot_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/widgets/decision_resources_editor.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';
import 'package:union_state/union_state.dart';

/// Тело экрана «Ресурсы»: загрузка, ошибка, форма бюджета и склада.
class DecisionResourcesBody extends StatelessWidget {
  /// Создаёт виджет.
  const DecisionResourcesBody({
    required this.bodyState,
    required this.onRetry,
    required this.wm,
    super.key,
  });

  /// Состояние данных формы.
  final UnionStateListenable<DecisionResourcesSnapshotEntity> bodyState;

  /// Повторить загрузку после ошибки.
  final VoidCallback onRetry;

  /// Widget model.
  final DecisionResourcesScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return UnionStateListenableBuilder<DecisionResourcesSnapshotEntity>(
      unionStateListenable: bodyState,
      loadingBuilder: (context, last) => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.double24),
          child: CircularProgressIndicator(),
        ),
      ),
      failureBuilder: (context, exception, last) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exception?.toString() ??
                    TasksDecisionStrings.resourcesLoadError(context),
                style: AppTextStyle.t14.value.copyWith(color: colorScheme.red),
                textAlign: TextAlign.center,
              ),
              const Height(AppSizes.double16),
              FilledButton(
                onPressed: onRetry,
                child: Text(TasksDecisionStrings.resourcesRetry(context)),
              ),
            ],
          ),
        );
      },
      builder: (context, _) {
        return DecisionResourcesEditor(
          wm: wm,
          onRetryLoad: onRetry,
        );
      },
    );
  }
}
