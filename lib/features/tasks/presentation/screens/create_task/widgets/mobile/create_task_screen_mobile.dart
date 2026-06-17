import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/mobile/create_task_mobile_content.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/mobile/create_task_mobile_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/mobile/create_task_mobile_loading.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран создания/редактирования задачи (mobile).
class CreateTaskScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const CreateTaskScreenMobile({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bootstrapBodyState,
      loadingBuilder: (context, last) =>
          CreateTaskMobileLoading(wm: wm),
      builder: (context, data) =>
          CreateTaskMobileContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return CreateTaskMobileFailure(
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
