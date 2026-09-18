import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Ошибка загрузки списка задач (desktop).
class TasksDesktopFailure extends StatelessWidget {
  /// Создаёт виджет.
  const TasksDesktopFailure({
    required this.wm,
    required this.error,
    super.key,
  });

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  /// Объект ошибки.
  final Object error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TasksStrings.errorAppBarTitle(context)),
        withBackButton: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: wm.onAddTask,
        child: Icon(Icons.add, color: colorScheme.primaryNormal),
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(TasksStrings.loadError(context)),
            const Height(AppSizes.double8),
            Text(
              error.toString(),
              style: AppTextScheme.of(context).body.t14,
            ),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: wm.retryTasksStream,
              child: Text(TasksStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
