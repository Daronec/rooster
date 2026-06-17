import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/widgets/decision_today_body.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Экран «Сегодня» (desktop).
class DecisionTodayScreenDesktop extends StatelessWidget {
  /// Создаёт экран.
  const DecisionTodayScreenDesktop({required this.wm, super.key});

  /// Widget model.
  final DecisionTodayScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.edgeInsetsAll16,
      child: DecisionTodayBody(
        bodyState: wm.bodyState,
        showMore: wm.onShowMore,
        openTask: wm.onOpenTask,
        retry: wm.onRetryStream,
      ),
    );
  }
}
