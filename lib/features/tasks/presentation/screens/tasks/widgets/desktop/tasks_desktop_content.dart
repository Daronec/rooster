import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/tasks_decision_debug_panel.dart';
import 'package:rooster/features/tasks/presentation/widgets/tasks_grouped_list_body.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Контент экрана списка задач (desktop): AppBar, FAB и сгруппированный список.
class TasksDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const TasksDesktopContent({required this.wm, super.key});

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TasksStrings.screenTitle(context)),
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
          children: [
            TasksDecisionDebugPanel(widgetModel: wm),
            Expanded(child: TasksGroupedListBody(wm: wm)),
          ],
        ),
      ),
    );
  }
}
