import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка загрузки экрана планирования (mobile).
class PlanningMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const PlanningMobileFailure({
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
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(PlanningStrings.screenTitle(context)),
        withBackButton: false,
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(error.toString()),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: wm.retryPlansStream,
              child: Text(PlanningStrings.retry(context)),
            ),
          ],
        ),
      ),
    );
  }
}
