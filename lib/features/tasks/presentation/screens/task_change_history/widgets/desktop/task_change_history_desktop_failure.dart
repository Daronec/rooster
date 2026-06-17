import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/strings/task_change_history_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка загрузки истории изменений (desktop).
class TaskChangeHistoryDesktopFailure extends StatelessWidget {
  /// Создаёт виджет.
  const TaskChangeHistoryDesktopFailure({required this.onRetry, super.key});

  /// Повторить загрузку.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TaskChangeHistoryStrings.screenTitle(context)),
        onBackButtonTap: () => context.router.maybePop(),
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(TaskChangeHistoryStrings.loadError(context)),
            const Height(AppSizes.double12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(TaskChangeHistoryStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}

