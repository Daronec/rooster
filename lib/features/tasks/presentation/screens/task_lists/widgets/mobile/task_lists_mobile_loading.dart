import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/task_lists_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Загрузка экрана списков задач (mobile).
class TaskListsMobileLoading extends StatelessWidget {
  /// Создаёт виджет.
  const TaskListsMobileLoading({required this.wm, super.key});

  /// Widget model экрана.
  final TaskListsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const DefaultAppBar(
        title: Text('Списки'),
        withBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(TaskListsStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
