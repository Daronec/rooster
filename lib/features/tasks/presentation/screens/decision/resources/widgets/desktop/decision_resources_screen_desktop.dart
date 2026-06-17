import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/widgets/decision_resources_body.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Экран «Ресурсы» (desktop).
class DecisionResourcesScreenDesktop extends StatelessWidget {
  /// Создаёт экран.
  const DecisionResourcesScreenDesktop({required this.wm, super.key});

  /// Widget model.
  final DecisionResourcesScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.edgeInsetsAll16,
      child: DecisionResourcesBody(
        bodyState: wm.bodyState,
        onRetry: wm.onRetry,
        wm: wm,
      ),
    );
  }
}
