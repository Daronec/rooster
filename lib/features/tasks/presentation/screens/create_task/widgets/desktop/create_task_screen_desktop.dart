import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/desktop/create_task_desktop_content.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/desktop/create_task_desktop_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/desktop/create_task_desktop_loading.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран создания/редактирования задачи (desktop).
class CreateTaskScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const CreateTaskScreenDesktop({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bootstrapBodyState,
      loadingBuilder: (context, last) =>
          CreateTaskDesktopLoading(wm: wm),
      builder: (context, data) =>
          CreateTaskDesktopContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return CreateTaskDesktopFailure(
          wm: wm,
          message:
              exception?.toString() ?? CreateTasksStrings.listsError(context),
          onRetry: () {
            unawaited(wm.retryBootstrap());
          },
        );
      },
    );
  }
}
