import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/task_detail_scroll_view.dart';
import 'package:rooster/features/tasks/presentation/strings/task_detail_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Контент экрана деталей задачи (mobile).
class TaskDetailMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const TaskDetailMobileContent({
    required this.wm,
    required this.task,
    super.key,
  });

  /// Widget model экрана деталей.
  final TaskDetailScreenWidgetModel wm;

  /// Задача.
  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TaskDetailStrings.screenTitle(context)),
        onBackButtonTap: () {
          context.router.maybePop();
        },
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                unawaited(wm.onEdit());
              } else if (value == 'share') {
                unawaited(wm.onShareTask());
              } else if (value == 'delete') {
                unawaited(wm.onConfirmDelete());
              }
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(TaskDetailStrings.editAction(context)),
                ),
                PopupMenuItem<String>(
                  value: 'share',
                  child: Text(TaskDetailStrings.shareAction(context)),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(TasksStrings.menuDelete(context)),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSizes.edgeInsetsAll16,
        child: TaskDetailScrollView(wm: wm, task: task),
      ),
    );
  }
}
