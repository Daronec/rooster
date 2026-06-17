import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/task_change_history_list.dart';
import 'package:rooster/features/tasks/presentation/strings/task_change_history_strings.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';

/// Контент истории изменений (desktop).
class TaskChangeHistoryDesktopContent extends StatelessWidget {
  /// Создаёт виджет.
  const TaskChangeHistoryDesktopContent({
    required this.wm,
    required this.changes,
    super.key,
  });

  /// Widget model экрана.
  final TaskChangeHistoryScreenWidgetModel wm;

  /// Записи истории.
  final List<TaskChangeEntity> changes;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TaskChangeHistoryStrings.screenTitle(context)),
        onBackButtonTap: () => context.router.maybePop(),
      ),
      body: TaskChangeHistoryList(items: changes),
    );
  }
}

