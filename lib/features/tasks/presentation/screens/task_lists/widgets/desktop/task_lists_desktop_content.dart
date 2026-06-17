import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_wm.dart';
import 'package:rooster/features/tasks/presentation/widgets/task_list_item.dart';
import 'package:rooster/features/tasks/presentation/strings/create_task_list_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/task_lists_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/util/app_hero_tags.dart';

/// Контент экрана списков задач (desktop).
class TaskListsDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const TaskListsDesktopContent({required this.wm, super.key});

  /// Widget model экрана.
  final TaskListsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return ValueListenableBuilder<List<TaskListEntity>>(
      valueListenable: wm.listsListenable,
      builder: (
        context,
        lists,
        _,
      ) {
        return AppScaffold(
          appBar: DefaultAppBar(
            title: Text(TaskListsStrings.screenTitle(context)),
            withBackButton: false,
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: AppHeroTags.fabTaskListsCreateList,
            tooltip: CreateTaskListStrings.fabTooltip(context),
            onPressed: wm.onCreateList,
            child: Icon(Icons.add, color: colorScheme.primaryNormal),
          ),
          body: Padding(
            padding: AppSizes.edgeInsetsAll16,
            child: ListView.separated(
              itemCount: lists.length,
              separatorBuilder: (_, __) => const Height(AppSizes.double8),
              itemBuilder: (context, index) {
                return TaskListItem(
                  task: lists[index],
                  onEdit: wm.onEditList,
                  onDelete: wm.onConfirmDeleteList,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
