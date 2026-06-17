import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_participant_picker.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_reminder_section.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/bottom_sheet/app_bottom_sheet.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Декоративная панель управления задачей.
class CreateTaskActionPanel extends StatelessWidget {
  /// Создаёт панель управления.
  const CreateTaskActionPanel({required this.wm, super.key});

  /// Widget model экрана создания задачи.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.double16),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.black.withValues(alpha: 0.08),
            blurRadius: AppSizes.double20,
            offset: const Offset(0, AppSizes.double8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.double10,
          AppSizes.double6,
          AppSizes.double10,
          AppSizes.double8,
        ),
        child: Row(
          children: <Widget>[
            _CreateTaskActionPanelItem(
              icon: Icons.flag_outlined,
              iconColor: colorScheme.red,
              label: CreateTasksStrings.sectionPriority(context),
              showsDropdown: true,
              onTap: () => _showPrioritySheet(context),
            ),
            if (!wm.isEditingTask) const Width(AppSizes.double16),
            if (wm.isEditingTask) const Spacer(),

            _CreateTaskActionPanelItem(
              icon: Icons.person_outline,
              iconColor: colorScheme.primaryNormal,
              label: CreateTasksStrings.fieldExecutor(context),
              showsDropdown: true,
              onTap: () => _showParticipantSheet(context),
            ),
            if (!wm.isEditingTask) const Width(AppSizes.double16),
            if (wm.isEditingTask) const Spacer(),

            _CreateTaskActionPanelItem(
              icon: Icons.notifications_none,
              iconColor: colorScheme.primaryNormal,
              label: CreateTasksStrings.actionPanelNotifications(context),
              showsDropdown: true,
              onTap: () => _showReminderSheet(context),
            ),
            if (!wm.isEditingTask) const Width(AppSizes.double16),
            if (wm.isEditingTask) const Spacer(),
            if (wm.isEditingTask) ...<Widget>[
              _CreateTaskActionPanelItem(
                icon: Icons.push_pin_outlined,
                iconColor: colorScheme.gray700,
                label: TasksStrings.menuPin(context),
                onTap: wm.onTogglePinnedEditingTask,
              ),
              const Spacer(),
              _CreateTaskActionPanelItem(
                icon: Icons.block,
                iconColor: colorScheme.warning,
                label: TasksStrings.menuCancel(context),
                onTap: wm.onCancelEditingTask,
              ),
              const Spacer(),
              _CreateTaskActionPanelItem(
                icon: Icons.delete_outline,
                iconColor: colorScheme.red,
                label: TasksStrings.menuDelete(context),
                onTap: wm.onConfirmDeleteEditingTask,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showPrioritySheet(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      _CreateTaskPrioritySheet(wm: wm),
    );
  }

  Future<void> _showParticipantSheet(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      _CreateTaskPanelSheetContent(
        title: CreateTasksStrings.fieldExecutor(context),
        child: TaskParticipantPicker(wm: wm),
      ),
    );
  }

  Future<void> _showReminderSheet(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      _CreateTaskPanelSheetContent(
        title: CreateTasksStrings.actionPanelNotifications(context),
        child: ValueListenableBuilder<String?>(
          valueListenable: wm.formState.reminderPresetListenable,
          builder: (context, _, __) => TaskReminderSection(wm: wm),
        ),
      ),
    );
  }
}

class _CreateTaskActionPanelItem extends StatelessWidget {
  const _CreateTaskActionPanelItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.showsDropdown = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool showsDropdown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth + (showsDropdown ? 4 : 0);
        final tileSize = itemWidth.clamp(
          AppSizes.double24,
          AppSizes.double36,
        );
        final iconSize = itemWidth < AppSizes.double40
            ? AppSizes.double16
            : itemWidth < AppSizes.double48
            ? AppSizes.double16
            : AppSizes.double24;
        final dropdownSize = itemWidth < AppSizes.double64
            ? AppSizes.double16
            : AppSizes.double20;
        return SizedBox(
          height: AppSizes.double40,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppSizes.borderRadius12,
              child: Semantics(
                button: true,
                label: label,
                child: Row(
                  children: [
                    SizedBox(
                      width: tileSize,
                      height: tileSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.gray100.withValues(alpha: 0.5),
                          borderRadius: AppSizes.borderRadius12,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Icon(
                              icon,
                              color: iconColor,
                              size: iconSize,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showsDropdown)
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.gray700,
                        size: dropdownSize,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreateTaskPanelSheetContent extends StatelessWidget {
  const _CreateTaskPanelSheetContent({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.double16,
          AppSizes.double8,
          AppSizes.double16,
          AppSizes.double24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: textScheme.body.t16Medium,
            ),
            const Height(AppSizes.double16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CreateTaskPrioritySheet extends StatelessWidget {
  const _CreateTaskPrioritySheet({required this.wm});

  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return _CreateTaskPanelSheetContent(
      title: CreateTasksStrings.sectionPriority(context),
      child: ValueListenableBuilder<String?>(
        valueListenable: wm.formState.priorityListenable,
        builder: (context, selectedId, _) {
          final selectedPriority = _parsePriority(selectedId);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskPriorityEntity.values
                .map(
                  (priority) => ListTile(
                    onTap: () {
                      wm.formState.setPriority(priority);
                      context.router.pop();
                    },
                    title: Text(
                      CreateTasksStrings.priority(context, priority.name),
                    ),
                    trailing: selectedPriority == priority
                        ? const Icon(Icons.check)
                        : null,
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }

  TaskPriorityEntity _parsePriority(String? id) {
    return TaskPriorityEntity.values.firstWhere(
      (priority) => priority.name == id,
      orElse: () => TaskPriorityEntity.normal,
    );
  }
}
