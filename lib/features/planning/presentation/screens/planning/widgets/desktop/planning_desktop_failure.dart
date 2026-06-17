import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Ошибка загрузки экрана планирования (desktop).
class PlanningDesktopFailure extends StatelessWidget {
  /// Создаёт виджет.
  const PlanningDesktopFailure({
    required this.wm,
    required this.error,
    super.key,
  });

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  /// Ошибка.
  final Object error;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.double24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(PlanningStrings.screenTitle(context), style: textScheme.t24),
            const Height(AppSizes.double24),
            Text(error.toString()),
            const Height(AppSizes.double16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: wm.retryPlansStream,
                child: Text(PlanningStrings.retry(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
