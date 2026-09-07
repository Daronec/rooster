import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/fields/widgets/common/app_dropdown.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';
import 'package:rooster/util/union_state/union_state_list_body.dart';

/// Выбор списка задач: загрузка/ошибка/пусто + выпадающий список.
final class TaskListPicker extends StatelessWidget {
  /// Создаёт виджет.
  const TaskListPicker({
    required this.wm,
    required this.listsLoadingBuilder,
    required this.listsFailureBuilder,
    super.key,
  });

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  /// Ветка загрузки списков в [UnionStateListBody] (платформенный виджет).
  final Widget Function(
    BuildContext context,
    List<TaskListEntity>? cached,
  ) listsLoadingBuilder;

  /// Ветка ошибки загрузки списков.
  final Widget Function(
    BuildContext context,
    Exception? exception,
    List<TaskListEntity>? cached,
  ) listsFailureBuilder;

  @override
  Widget build(BuildContext context) {
    return UnionStateListBody<TaskListEntity>(
      unionStateListenable: wm.listsLoadState,
      loadingBuilder: listsLoadingBuilder,
      failureBuilder: listsFailureBuilder,
      builder: (context, lists) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          wm.selectDefaultListIfNeeded(lists);
        });
        if (lists.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                CreateTasksStrings.listsEmptyTitle(context),
                style: AppTextStyle.t16Bold.value,
              ),
              const Height(AppSizes.double8),
              Text(
                CreateTasksStrings.listsEmptySubtitle(context),
                style: AppTextStyle.t14.value,
              ),
              const Height(AppSizes.double16),
              FilledButton(
                onPressed: wm.onOpenTaskListsTab,
                child: Text(CreateTasksStrings.openListsTab(context)),
              ),
            ],
          );
        }
        return ListenableBuilder(
          listenable: wm.formState,
          builder: (context, _) {
            final selected = wm.formState.selectedListIdListenable.value;
            final options = lists
                .map(
                  (list) => AppDropdownEntity(
                    id: list.id,
                    label: list.name,
                  ),
                )
                .toList(growable: true);
            if (selected != null &&
                selected.isNotEmpty &&
                !options.any((o) => o.id == selected)) {
              options.insert(
                0,
                AppDropdownEntity(
                  id: selected,
                  label: TasksStrings.unknownList(context),
                ),
              );
            }
            return AppDropdown(
              label: CreateTasksStrings.fieldList(context),
              emptyMessage: CreateTasksStrings.listsEmptyTitle(context),
              placeholder: CreateTasksStrings.fieldList(context),
              valueListenable: wm.formState.selectedListIdListenable,
              options: options.toList(growable: false),
              onChanged: wm.formState.setSelectedListId,
            );
          },
        );
      },
    );
  }
}




