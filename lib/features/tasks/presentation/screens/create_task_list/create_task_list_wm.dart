import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_color_presets.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_model.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_screen.dart';
import 'package:rooster/features/tasks/presentation/strings/create_task_list_strings.dart';
import 'package:uuid/uuid.dart';

/// WM экрана создания списка задач.
class CreateTaskListScreenWidgetModel
    extends BaseWidgetModel<CreateTaskListScreen, CreateTaskListScreenModel> {
  /// Создаёт WM.
  CreateTaskListScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required Uuid uuid,
  }) : _uuid = uuid,
       selectedColorArgb = ValueNotifier<int>(
         CreateTaskListColorPresets.defaultArgb,
       ),
       super(
         handledFailureLogWriter: logWriter,
       );

  final Uuid _uuid;

  /// Поле названия списка.
  final TextEditingController nameController = TextEditingController();

  /// Выбранный цвет (ARGB).
  final ValueNotifier<int> selectedColorArgb;

  /// Режим редактирования существующего списка.
  bool get isEditingList => model.editingListId != null;

  /// Доступные пресеты цвета.
  List<int> get colorPresetArgbValues => CreateTaskListColorPresets.argbValues;

  /// Выбрать цвет из пресета.
  void selectColorPreset(int argb) {
    selectedColorArgb.value = argb;
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    unawaited(_hydrateEditingList());
  }

  Future<void> _hydrateEditingList() async {
    final listId = model.editingListId;
    if (listId == null) {
      return;
    }
    final list = await model.loadList(listId);
    if (!context.mounted) {
      return;
    }
    if (list == null) {
      snackController.addSnack(
        CreateTaskListStrings.editListNotFound(context),
        messageType: SnackMessageType.warning,
      );
      await context.router.maybePop();
      return;
    }
    nameController.text = list.name;
    selectedColorArgb.value = list.colorArgb;
  }

  /// Сохранить список и закрыть экран.
  Future<void> onSave() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      snackController.addSnack(
        CreateTaskListStrings.validationNameEmpty(context),
        messageType: SnackMessageType.warning,
      );
      return;
    }
    final editingId = model.editingListId;
    final id = editingId ?? _uuid.v4();
    try {
      await model.saveList(
        TaskListEntity(
          id: id,
          name: name,
          colorArgb: selectedColorArgb.value,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        editingId != null
            ? CreateTaskListStrings.updateSuccessSnack(context)
            : CreateTaskListStrings.successSnack(context),
        messageType: SnackMessageType.success,
      );
      await context.router.maybePop();
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Закрыть без сохранения.
  Future<void> onCancel() async {
    await context.router.maybePop();
  }

  @override
  void dispose() {
    nameController.dispose();
    selectedColorArgb.dispose();
    super.dispose();
  }
}
