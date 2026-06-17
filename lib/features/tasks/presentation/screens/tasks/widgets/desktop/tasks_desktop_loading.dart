import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Состояние загрузки списка задач (desktop).
class TasksDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const TasksDesktopLoading({required this.wm, super.key});

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return AppScaffold(
      appBar: const DefaultAppBar(
        title: Text('Задачи'),
        withBackButton: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: wm.onAddTask,
        child: Icon(Icons.add, color: colorScheme.primaryNormal),
      ),
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(TasksStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
