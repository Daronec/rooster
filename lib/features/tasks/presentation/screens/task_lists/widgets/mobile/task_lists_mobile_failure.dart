import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/task_lists_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка загрузки экрана списков (mobile).
class TaskListsMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const TaskListsMobileFailure({
    required this.wm,
    required this.error,
    super.key,
  });

  /// Widget model экрана.
  final TaskListsScreenWidgetModel wm;

  /// Ошибка.
  final Object error;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const DefaultAppBar(
        title: Text('Списки'),
        withBackButton: false,
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(TaskListsStrings.loadError(context)),
            const Height(AppSizes.double8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: wm.retryListsStream,
              child: Text(TaskListsStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
