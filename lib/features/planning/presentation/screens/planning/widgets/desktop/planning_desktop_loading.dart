import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Загрузка экрана планирования (desktop).
class PlanningDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const PlanningDesktopLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.double24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(PlanningStrings.screenTitle(context), style: textScheme.t24),
            const Height(AppSizes.double24),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
