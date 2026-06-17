import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/decision_blocked_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/widgets/decision_blocked_body.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Экран «Заблокировано» (desktop).
class DecisionBlockedScreenDesktop extends StatelessWidget {
  /// Создаёт экран.
  const DecisionBlockedScreenDesktop({required this.wm, super.key});

  /// Модель виджета экрана «Заблокировано».
  final DecisionBlockedScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.edgeInsetsAll16,
      child: DecisionBlockedBody(
        bodyState: wm.bodyState,
        openTask: wm.onOpenTask,
        createMaterialPurchaseTask: wm.onCreateMaterialPurchaseTask,
        retry: wm.onRetryStream,
      ),
    );
  }
}
