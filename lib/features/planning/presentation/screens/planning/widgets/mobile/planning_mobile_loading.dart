import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Загрузка экрана планирования (mobile).
class PlanningMobileLoading extends StatelessWidget {
  /// Создаёт виджет.
  const PlanningMobileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(PlanningStrings.screenTitle(context)),
        withBackButton: false,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            Height(AppSizes.double16),
          ],
        ),
      ),
    );
  }
}
