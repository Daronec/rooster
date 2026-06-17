import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/create_task_form_scaffold.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/desktop/create_task_desktop_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/desktop/create_task_desktop_loading.dart';

/// Контент экрана создания/редактирования задачи (desktop): форма после bootstrap.
class CreateTaskDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const CreateTaskDesktopContent({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return CreateTaskFormScaffold(
      wm: wm,
      listsLoadingBuilder: (context, _) =>
          const CreateTaskDesktopListsLoadingPanel(),
      listsFailureBuilder: (context, exception, _) {
        return CreateTaskDesktopListsFailurePanel(onRetry: wm.onRetryLoadLists);
      },
    );
  }
}
