import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/strings/task_change_history_strings.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Загрузка истории изменений (mobile).
class TaskChangeHistoryMobileLoading extends StatelessWidget {
  /// Создаёт виджет.
  const TaskChangeHistoryMobileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TaskChangeHistoryStrings.screenTitle(context)),
        onBackButtonTap: () => context.router.maybePop(),
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Text(TaskChangeHistoryStrings.loadingBody(context)),
      ),
    );
  }
}

