import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_creation_input_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_weekday_mask_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_participant_entity.dart';
import 'package:rooster/features/tasks/domain/services/task_creation_input_from_task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_form_state.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_material_rows_notifier.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_model.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_screen.dart';
import 'package:rooster/features/tasks/presentation/sounds/i_task_completion_sound_player.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/fields/widgets/common/app_dropdown.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/util/extensions/value_notifier_x.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:union_state/union_state.dart';

/// WM экрана создания задачи.
class CreateTaskScreenWidgetModel
    extends BaseWidgetModel<CreateTaskScreen, CreateTaskScreenModel> {
  /// Создаёт WM.
  CreateTaskScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required CreateTaskFormState formState,
    required ITaskCompletionSoundPlayer taskCompletionSoundPlayer,
  }) : _formState = formState,
       _taskCompletionSoundPlayer = taskCompletionSoundPlayer,
       materialRows = CreateTaskMaterialRowsNotifier(),
       bootstrapBodyState = UnionStateNotifier<EmptyScreenBody>.loading(),
       super(
         handledFailureLogWriter: logWriter,
       );

  final CreateTaskFormState _formState;
  final ITaskCompletionSoundPlayer _taskCompletionSoundPlayer;

  /// Динамические строки материалов (название, количество, стоимость).
  final CreateTaskMaterialRowsNotifier materialRows;

  /// Первичная загрузка: списки и задача для редактирования.
  final UnionStateNotifier<EmptyScreenBody> bootstrapBodyState;

  /// Состояние полей формы (кроме текстовых контроллеров).
  CreateTaskFormState get formState => _formState;

  /// Загрузка списков задач для формы (UnionState).
  UnionStateListenable<List<TaskListEntity>> get listsLoadState =>
      model.listsState;

  /// Позиции склада материалов (из вкладки «Ресурсы») для выпадающего выбора.
  ValueNotifier<List<MaterialStockItemEntity>>
  get materialStockItemsListenable => model.materialStockItemsListenable;

  /// Индикатор загрузки участников из команд.
  ValueNotifier<bool> get participantsLoadingListenable =>
      model.participantsLoadingListenable;

  /// Участники (из команд Appwrite) для выбора.
  ValueNotifier<List<TaskParticipantEntity>> get participantsListenable =>
      model.participantsListenable;

  /// Опции для выпадающих списков ролей задачи.
  List<AppDropdownEntity> get participantDropdownOptions {
    final items = model.participantsListenable.value;
    final options = items
        .where((participant) => participant.userId.trim().isNotEmpty)
        .map(
          (participant) => AppDropdownEntity(
            id: '${participant.teamId}:${participant.userId}',
            label: participant.label.trim().isEmpty
                ? participant.userId
                : participant.label,
          ),
        )
        .toList(growable: true);

    _addSelectedRoleOptionIfMissing(
      options: options,
      teamId: _formState.executorTeamId,
      userId: _formState.executorUserId,
    );
    _addSelectedRoleOptionIfMissing(
      options: options,
      teamId: _formState.observerTeamId,
      userId: _formState.observerUserId,
    );
    return options.toList(growable: false);
  }

  void _addSelectedRoleOptionIfMissing({
    required List<AppDropdownEntity> options,
    required String? teamId,
    required String? userId,
  }) {
    final selectedTeamId = teamId?.trim() ?? '';
    final selectedUserId = userId?.trim() ?? '';
    if (selectedTeamId.isEmpty || selectedUserId.isEmpty) {
      return;
    }
    final selectedKey = '$selectedTeamId:$selectedUserId';
    final alreadyPresent = options.any((option) => option.id == selectedKey);
    if (alreadyPresent) {
      return;
    }
    options.insert(
      0,
      AppDropdownEntity(
        id: selectedKey,
        label: selectedUserId,
      ),
    );
  }

  /// Опции для выпадающего списка материалов.
  List<AppDropdownEntity> get materialStockDropdownOptions {
    final items = model.materialStockItemsListenable.value;
    return items
        .where((item) => item.id.trim().isNotEmpty)
        .map(
          (item) => AppDropdownEntity(
            id: item.id,
            label: item.name.trim().isEmpty ? item.id : item.name,
          ),
        )
        .toList(growable: false);
  }

  /// Выбор материала со склада для строки материалов.
  void onSelectMaterialStockItem({
    required String rowId,
    required String? stockItemId,
  }) {
    CreateTaskMaterialRowBinding? targetRow;
    for (final row in materialRows.rows) {
      if (row.id == rowId) {
        targetRow = row;
        break;
      }
    }
    final resolvedRow = targetRow;
    if (resolvedRow == null) {
      return;
    }
    resolvedRow.stockItemIdListenable.value = stockItemId;
    if (stockItemId == null || stockItemId.isEmpty) {
      return;
    }
    MaterialStockItemEntity? selectedItem;
    for (final item in model.materialStockItemsListenable.value) {
      if (item.id == stockItemId) {
        selectedItem = item;
        break;
      }
    }
    final resolvedItem = selectedItem;
    if (resolvedItem == null) {
      return;
    }
    final trimmedName = resolvedItem.name.trim();
    if (trimmedName.isEmpty) {
      return;
    }
    resolvedRow.nameController.text = trimmedName;

    final quantityText = resolvedRow.quantityController.text.trim();
    if (quantityText.isEmpty) {
      resolvedRow.quantityController.text = '1';
    }
  }

  /// Подзадачи редактируемой задачи.
  ValueNotifier<List<TaskEntity>> get subtasksListenable =>
      model.subtasksListenable;

  /// Все задачи для выбора родителя.
  ValueNotifier<List<TaskEntity>> get allTasksListenable =>
      model.allTasksListenable;

  /// Заголовок задачи по её id или null.
  String? taskTitleById(String? taskId) {
    if (taskId == null || taskId.isEmpty) {
      return null;
    }
    for (final task in model.allTasksListenable.value) {
      if (task.id == taskId) {
        return task.title;
      }
    }
    return null;
  }

  /// Состояние сохранения задачи.
  PageStateNotifier get taskSaveState => model.saveState;

  /// Режим редактирования существующей задачи.
  bool get isEditingTask => model.editingTaskId != null;

  /// Id редактируемой задачи (null для режима создания).
  String? get editingTaskId => model.editingTaskId;

  /// Контроллер заголовка.
  final TextEditingController titleController = TextEditingController();

  /// Контроллер описания.
  final TextEditingController descriptionController = TextEditingController();

  /// Контроллер тегов (через запятую).
  final TextEditingController tagsController = TextEditingController();

  /// Контроллер тегов для поля ввода (chips + разделители).
  final StringTagController tagsFieldController = StringTagController();

  /// Текущий текст поля тегов, который ещё не стал chip.
  String pendingTagsInput = '';

  /// Теги для первичной регистрации [tagsFieldController] в [TaskTagsField].
  List<String> get initialTagsForField => List<String>.unmodifiable(
    _parseTags(tagsController.text),
  );

  /// Оценочная стоимость выполнения (число; пусто — ноль).
  final TextEditingController estimatedCostController = TextEditingController();

  Timer? _autosaveDebounce;
  bool _autosaveEnabled = false;
  bool _isHydrating = false;
  int _autosaveGeneration = 0;
  TaskEntity? _loadedEditingTask;
  final Map<String, VoidCallback> _materialRowListenerDisposers =
      <String, VoidCallback>{};

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _bindAutosaveListeners();
    unawaited(_bootstrap());
  }

  /// Загрузка списков и, при редактировании, данных задачи.
  Future<void> _bootstrap() async {
    bootstrapBodyState.loading();
    try {
      await model.loadLists();
      await model.loadMaterialStock();
      await model.loadParticipantsFromTeams();
      _debugLogParticipantsSnapshot('after_load_participants');
      if (model.editingTaskId == null) {
        await _hydrateNewTaskDefaultsIfNeeded();
        if (!context.mounted) {
          return;
        }
        _autosaveEnabled = false;
        bootstrapBodyState.content(EmptyScreenBody.instance);
        return;
      }
      final task = await model.loadEditingTask();
      if (!context.mounted) {
        return;
      }
      if (task == null) {
        snackController.addSnack(
          CreateTasksStrings.editTaskNotFound(context),
          messageType: SnackMessageType.warning,
        );
        await context.router.maybePop();
        return;
      }
      _isHydrating = true;
      applyLoadedTask(task);
      _isHydrating = false;
      _debugLogParticipantsSnapshot('after_apply_loaded_task');
      if (!context.mounted) {
        return;
      }
      _autosaveEnabled = true;
      bootstrapBodyState.content(EmptyScreenBody.instance);
    } on Object catch (error) {
      if (context.mounted) {
        bootstrapBodyState.failure(
          error is Exception ? error : Exception(error.toString()),
          null,
        );
      }
    }
  }

  void _bindAutosaveListeners() {
    void schedule() => _scheduleAutosave();

    titleController.addListener(schedule);
    descriptionController.addListener(schedule);
    tagsController.addListener(schedule);
    tagsFieldController.addListener(schedule);
    estimatedCostController.addListener(schedule);
    _formState.addListener(schedule);
    materialRows.addListener(() {
      _rebindMaterialRowControllerListeners();
      _scheduleAutosave();
    });
    _rebindMaterialRowControllerListeners();
  }

  void _rebindMaterialRowControllerListeners() {
    final active = <String>{};
    for (final row in materialRows.rows) {
      void ensure(TextEditingController controller, String kind) {
        final key = '${row.id}_$kind';
        active.add(key);
        if (_materialRowListenerDisposers.containsKey(key)) {
          return;
        }
        void listener() => _scheduleAutosave();
        controller.addListener(listener);
        _materialRowListenerDisposers[key] = () {
          controller.removeListener(listener);
        };
      }

      void ensureListenable(Listenable listenable, String kind) {
        final key = '${row.id}_$kind';
        active.add(key);
        if (_materialRowListenerDisposers.containsKey(key)) {
          return;
        }
        void listener() => _scheduleAutosave();
        listenable.addListener(listener);
        _materialRowListenerDisposers[key] = () {
          listenable.removeListener(listener);
        };
      }

      ensure(row.nameController, 'name');
      ensure(row.quantityController, 'qty');
      ensure(row.costController, 'cost');
      ensureListenable(row.stockItemIdListenable, 'stock');
    }
    final obsolete = _materialRowListenerDisposers.keys
        .where((key) => !active.contains(key))
        .toList(growable: false);
    for (final key in obsolete) {
      _materialRowListenerDisposers.remove(key)?.call();
    }
  }

  void _scheduleAutosave() {
    if (!_autosaveEnabled || !isEditingTask) {
      return;
    }
    if (_isHydrating) {
      return;
    }
    _autosaveGeneration++;
    final generation = _autosaveGeneration;
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 500), () {
      if (generation != _autosaveGeneration) {
        return;
      }
      unawaited(_autosaveNow());
    });
  }

  Future<void> _autosaveNow() async {
    if (!_autosaveEnabled || !isEditingTask) {
      return;
    }
    final input = _buildInputForSaveOrNull(quiet: true);
    if (input == null) {
      return;
    }
    final startedGeneration = ++_autosaveGeneration;
    try {
      await model.saveTask(input);
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }
      onErrorHandle(error);
      return;
    }
    if (startedGeneration != _autosaveGeneration) {
      _scheduleAutosave();
    }
  }

  Future<void> _hydrateNewTaskDefaultsIfNeeded() async {
    final initialTitle = model.initialTitle?.trim() ?? '';
    if (initialTitle.isNotEmpty && titleController.text.trim().isEmpty) {
      titleController.text = initialTitle;
    }
    final initialDescription = model.initialDescription?.trim() ?? '';
    if (initialDescription.isNotEmpty &&
        descriptionController.text.trim().isEmpty) {
      descriptionController.text = initialDescription;
    }
    if (_formState.parentTaskId == null || _formState.parentTaskId!.isEmpty) {
      return;
    }
    final parent = await model.loadTask(_formState.parentTaskId!);
    if (parent == null) {
      _formState.setParentTaskId(null);
      return;
    }
    if (_formState.selectedListId == null ||
        _formState.selectedListId!.isEmpty) {
      _formState.setSelectedListId(parent.listId);
    }
  }

  /// Повторить первичную загрузку после ошибки.
  Future<void> retryBootstrap() async {
    await _bootstrap();
  }

  /// Подставляет [task] в контроллеры и состояние формы.
  void applyLoadedTask(TaskEntity task) {
    _loadedEditingTask = task;
    titleController.text = task.title;
    descriptionController.text = task.description;
    tagsController.text = task.tags.join(', ');
    pendingTagsInput = '';
    estimatedCostController.text = task.estimatedCost == 0
        ? ''
        : _stripTrailingZeros(task.estimatedCost);
    _formState.hydrateFromCreationInput(
      TaskCreationInputFromTaskEntity.fromEntity(task),
    );
    materialRows.loadFromRequirements(task.materialRequirements);
  }

  void _debugLogParticipantsSnapshot(String tag) {
    if (!kDebugMode) {
      return;
    }
    final selectedTeamId = _formState.executorTeamId?.trim() ?? '';
    final selectedUserId = _formState.executorUserId?.trim() ?? '';
    final selectedKey = selectedTeamId.isEmpty || selectedUserId.isEmpty
        ? null
        : '$selectedTeamId:$selectedUserId';
    final items = model.participantsListenable.value;
    final head = items.take(10).map((p) => '${p.teamId}:${p.userId}').toList();
    debugPrint(
      'create_task_participants_snapshot tag=$tag '
      'selected=$selectedKey count=${items.length} head=$head',
    );
  }

  /// Нужно ли показывать владельца редактируемой задачи.
  bool get shouldShowOwner {
    final task = _loadedEditingTask;
    final ownerUserId = task?.ownerUserId?.trim() ?? '';
    final currentUserId = model.currentUser?.uid.trim() ?? '';
    return ownerUserId.isNotEmpty &&
        currentUserId.isNotEmpty &&
        ownerUserId != currentUserId;
  }

  /// Отображаемое имя владельца редактируемой задачи.
  String get ownerLabel {
    final task = _loadedEditingTask;
    final name = task?.ownerNameSnapshot.trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }
    return task?.ownerUserId?.trim() ?? '';
  }

  static String _stripTrailingZeros(double value) {
    final text = value.toString();
    if (!text.contains('.')) {
      return text;
    }
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  void dispose() {
    _autosaveDebounce?.cancel();
    _autosaveDebounce = null;
    for (final dispose in _materialRowListenerDisposers.values) {
      dispose();
    }
    _materialRowListenerDisposers.clear();
    bootstrapBodyState.dispose();
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    tagsFieldController.dispose();
    estimatedCostController.dispose();
    materialRows.dispose();
    _formState.dispose();
    unawaited(_taskCompletionSoundPlayer.dispose());
    super.dispose();
  }

  /// Повторить загрузку списков после ошибки.
  Future<void> onRetryLoadLists() async {
    await model.loadLists();
  }

  /// Выбор даты срока.
  Future<void> onPickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _formState.dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _formState.setDueDate(picked);
    }
  }

  /// Выбор времени начала.
  Future<void> onPickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _formState.startTime,
    );
    if (picked != null) {
      _formState.setStartTime(picked);
    }
  }

  /// Выбор времени окончания.
  Future<void> onPickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _formState.endTime,
    );
    if (picked != null) {
      _formState.setEndTime(picked);
    }
  }

  /// Выбор даты и времени произвольного напоминания.
  Future<void> onPickCustomReminder() async {
    final initial =
        _formState.customReminderAt ??
        DateTime(
          _formState.dueDate.year,
          _formState.dueDate.month,
          _formState.dueDate.day,
          9,
        );
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !context.mounted) {
      return;
    }
    _formState.setCustomReminderAt(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  /// Выбор времени постоянного напоминания.
  Future<void> onPickRecurrenceTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _formState.recurrenceTime,
    );
    if (picked != null) {
      _formState.setRecurrenceTime(picked);
    }
  }

  /// Добавить пустую строку материала.
  void onAddMaterialRow() {
    materialRows.addEmptyRow();
  }

  /// Удалить строку материала по [rowId].
  void onRemoveMaterialRow(String rowId) {
    materialRows.removeRow(rowId);
  }

  /// Обновить ещё не подтверждённый текст поля тегов и запланировать автосохранение.
  void onPendingTagsInputChanged(String value) {
    pendingTagsInput = value;
    _scheduleAutosave();
  }

  /// Очистить временный текст после добавления тега в chips.
  void onPendingTagsSubmitted() {
    pendingTagsInput = '';
    _scheduleAutosave();
  }

  /// Переключить день недели в маске постоянного напоминания.
  void onToggleWeekday(int dayBit) {
    final next = TaskWeekdayMaskEntity.toggle(
      _formState.recurrenceWeekdaysMask,
      dayBit,
    );
    _formState.setRecurrenceWeekdaysMask(next);
  }

  /// Выбор изображения из галереи.
  Future<void> onPickImages() async {
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage();
      if (files.isEmpty) {
        return;
      }
      _formState.addImageLocalPaths(files.map((file) => file.path));
    } on PlatformException catch (error) {
      snackController.addSnack(
        CreateTasksStrings.pickImageFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    } on Object catch (error) {
      snackController.addSnack(
        CreateTasksStrings.pickImageFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    }
  }

  /// Удалить изображение по индексу.
  void onRemoveImageAt(int index) {
    _formState.removeImageAt(index);
  }

  /// Перейти на вкладку «Списки» (если нет ни одного списка).
  void onOpenTaskListsTab() {
    final tabs = TabsRouterScope.of(context)?.controller;
    tabs?.setActiveIndex(1);
  }

  /// Закрыть экран без сохранения.
  Future<void> onCancel() async {
    await context.router.maybePop();
  }

  /// Добавить подзадачу для текущей редактируемой задачи.
  Future<void> onAddSubtask() async {
    final parentId = model.editingTaskId;
    if (parentId == null || parentId.isEmpty) {
      return;
    }
    await context.router.push<void>(
      CreateTaskRoute(parentTaskId: parentId),
    );
  }

  /// Выбрать родительскую задачу.
  Future<void> onPickParentTask() async {
    final currentId = model.editingTaskId;
    final candidates =
        model.allTasksListenable.value
            .where((task) {
              if (currentId != null && currentId.isNotEmpty) {
                if (task.id == currentId) {
                  return false;
                }
                if (task.parentTaskId == currentId) {
                  return false;
                }
              }
              return true;
            })
            .toList(growable: false)
          ..sort((a, b) => a.title.compareTo(b.title));

    final selectedId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.double16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  CreateTasksStrings.pickParentTaskTitle(sheetContext),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const Height(AppSizes.double12),
                if (candidates.isEmpty)
                  Text(CreateTasksStrings.pickParentTaskEmpty(sheetContext))
                else
                  Flexible(
                    child: ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final task = candidates[index];
                        return ListTile(
                          title: Text(task.title),
                          onTap: () {
                            sheetContext.router.pop(task.id);
                          },
                        );
                      },
                    ),
                  ),
                const Height(AppSizes.double12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          sheetContext.router.pop();
                        },
                        child: Text(
                          CreateTasksStrings.pickParentTaskCancel(sheetContext),
                        ),
                      ),
                    ),
                    const Width(AppSizes.double12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          sheetContext.router.pop('');
                        },
                        child: Text(
                          CreateTasksStrings.pickParentTaskClear(sheetContext),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedId == null || !context.mounted) {
      return;
    }
    _formState.setParentTaskId(selectedId.isEmpty ? null : selectedId);
  }

  /// Открыть редактирование подзадачи.
  Future<void> onEditTask(String taskId) async {
    await context.router.push<void>(CreateTaskRoute(taskId: taskId));
  }

  /// Открыть историю изменений текущей задачи.
  Future<void> onOpenChangeHistory() async {
    final taskId = model.editingTaskId;
    if (taskId == null || taskId.isEmpty) {
      return;
    }
    await context.router.push<void>(TaskChangeHistoryRoute(taskId: taskId));
  }

  /// Закрепить/открепить текущую задачу (в режиме редактирования).
  Future<void> onTogglePinnedEditingTask() async {
    final taskId = model.editingTaskId;
    if (taskId == null || taskId.isEmpty) {
      return;
    }
    final task = await model.loadTask(taskId);
    if (task == null) {
      return;
    }
    try {
      await model.saveExistingTask(
        task.copyWith(
          isPinned: !task.isPinned,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
          syncState: TaskSyncStateEntity.pendingSync,
        ),
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Отменить текущую задачу («Не буду делать») (в режиме редактирования).
  Future<void> onCancelEditingTask() async {
    final taskId = model.editingTaskId;
    if (taskId == null || taskId.isEmpty) {
      return;
    }
    final task = await model.loadTask(taskId);
    if (task == null) {
      return;
    }
    if (task.status == TaskStatusEntity.cancelled) {
      return;
    }
    try {
      await model.saveExistingTask(
        task.copyWith(
          status: TaskStatusEntity.cancelled,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
          syncState: TaskSyncStateEntity.pendingSync,
        ),
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Удалить текущую задачу с подтверждением (в режиме редактирования).
  Future<void> onConfirmDeleteEditingTask() async {
    final taskId = model.editingTaskId;
    if (taskId == null || taskId.isEmpty) {
      return;
    }
    final task = await model.loadTask(taskId);
    if (task == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TasksStrings.deleteConfirmTitle(context)),
          content: Text(TasksStrings.deleteConfirmMessage(context)),
          actions: <Widget>[
            TextButton(
              onPressed: () => dialogContext.router.pop(false),
              child: Text(TasksStrings.deleteCancel(context)),
            ),
            FilledButton(
              onPressed: () => dialogContext.router.pop(true),
              child: Text(TasksStrings.deleteConfirmAction(context)),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await model.deleteTask(task.id);
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        TasksStrings.deleteSuccess(context),
        messageType: SnackMessageType.success,
      );
      await context.router.maybePop();
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Удалить подзадачу с подтверждением.
  Future<void> onConfirmDeleteSubtask(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TasksStrings.deleteConfirmTitle(context)),
          content: Text(TasksStrings.deleteConfirmMessage(context)),
          actions: <Widget>[
            TextButton(
              onPressed: () => dialogContext.router.pop(false),
              child: Text(TasksStrings.deleteCancel(context)),
            ),
            FilledButton(
              onPressed: () => dialogContext.router.pop(true),
              child: Text(TasksStrings.deleteConfirmAction(context)),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await model.deleteTask(task.id);
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        TasksStrings.deleteSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Переключить выполнение подзадачи.
  Future<void> onToggleTaskCompleted(
    TaskEntity task, {
    required bool completed,
  }) async {
    final newStatus = completed
        ? TaskStatusEntity.completed
        : TaskStatusEntity.pending;
    if (task.status == newStatus) {
      return;
    }
    try {
      await model.setTaskCompleted(
        task: task,
        completed: completed,
      );
      if (completed) {
        unawaited(_taskCompletionSoundPlayer.playDoneTask());
      }
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  TaskCreationInputEntity? _buildInputForSaveOrNull({required bool quiet}) {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      if (!quiet) {
        snackController.addSnack(
          CreateTasksStrings.validationTitle(context),
          messageType: SnackMessageType.warning,
        );
      }
      return null;
    }
    final listId = _formState.selectedListId;
    if (listId == null || listId.isEmpty) {
      if (!quiet) {
        snackController.addSnack(
          CreateTasksStrings.validationList(context),
          messageType: SnackMessageType.warning,
        );
      }
      return null;
    }
    if (_formState.reminderPreset == TaskReminderPresetEntity.custom &&
        _formState.customReminderAt == null) {
      if (!quiet) {
        snackController.addSnack(
          CreateTasksStrings.validationCustomReminder(context),
          messageType: SnackMessageType.warning,
        );
      }
      return null;
    }
    final costRaw = estimatedCostController.text.trim().replaceAll(',', '.');
    double estimatedCost = 0;
    if (costRaw.isNotEmpty) {
      final parsed = double.tryParse(costRaw);
      if (parsed == null) {
        if (!quiet) {
          snackController.addSnack(
            CreateTasksStrings.validationEstimatedCost(context),
            messageType: SnackMessageType.warning,
          );
        }
        return null;
      }
      if (parsed < 0) {
        if (!quiet) {
          snackController.addSnack(
            CreateTasksStrings.validationEstimatedCostNegative(context),
            messageType: SnackMessageType.warning,
          );
        }
        return null;
      }
      estimatedCost = parsed;
    }
    final materialRequirements = _tryParseMaterialRequirements();
    if (materialRequirements == null) {
      return null;
    }
    final date = _formState.dueDate;
    final dueDateOnly = _formState.isAllDay ? date : null;
    final finalStart = _formState.isAllDay
        ? null
        : _combineDateAndTime(date, _formState.startTime);
    final finalEnd = _formState.isAllDay
        ? null
        : _endDateTimeWithOvernight(
            date,
            start: _formState.startTime,
            end: _formState.endTime,
          );

    final recurrenceMinutes = _formState.recurrenceWeekdaysMask == 0
        ? null
        : _formState.recurrenceTime.hour * 60 +
              _formState.recurrenceTime.minute;

    if (kDebugMode) {
      debugPrint(
        'create_task_build_input executorTeamId=${_formState.executorTeamId} '
        'executorUserId=${_formState.executorUserId} '
        'observerTeamId=${_formState.observerTeamId} '
        'observerUserId=${_formState.observerUserId}',
      );
    }

    return TaskCreationInputEntity(
      title: title,
      description: descriptionController.text,
      listId: listId,
      parentTaskId: _formState.parentTaskId,
      ownerUserId: _resolveOwnerUserId(),
      ownerNameSnapshot: _resolveOwnerNameSnapshot(),
      executorUserId: _formState.executorUserId,
      executorTeamId: _formState.executorTeamId,
      observerUserId: _formState.observerUserId,
      observerTeamId: _formState.observerTeamId,
      dependencyTaskIds: _formState.dependencyTaskIds,
      dueDateOnly: dueDateOnly,
      isAllDay: _formState.isAllDay,
      startAt: finalStart,
      endAt: finalEnd,
      reminderPreset: _formState.reminderPreset,
      customReminderAt: _formState.customReminderAt,
      recurrenceWeekdaysMask: _formState.recurrenceWeekdaysMask,
      recurrenceReminderMinutesFromMidnight: recurrenceMinutes,
      importance: _formState.importance,
      complexity: _formState.complexity,
      priority: _formState.priority,
      tags: _currentTagsForSave(),
      imageAttachments: List<TaskImageAttachmentEntity>.of(
        _formState.imageAttachments,
      ),
      estimatedCost: estimatedCost,
      materialRequirements: materialRequirements,
    );
  }

  String? _resolveOwnerUserId() {
    final existingOwner = _loadedEditingTask?.ownerUserId?.trim() ?? '';
    if (existingOwner.isNotEmpty) {
      return existingOwner;
    }
    final currentUserId = model.currentUser?.uid.trim() ?? '';
    return currentUserId.isEmpty ? null : currentUserId;
  }

  String _resolveOwnerNameSnapshot() {
    final existingOwnerName =
        _loadedEditingTask?.ownerNameSnapshot.trim() ?? '';
    if (existingOwnerName.isNotEmpty) {
      return existingOwnerName;
    }
    final user = model.currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName;
    }
    final email = user?.email?.trim() ?? '';
    if (email.isNotEmpty) {
      return email;
    }
    return user?.uid.trim() ?? '';
  }

  List<String> _currentTagsForSave() {
    final tags = <String>[];
    final fromController = tagsFieldController.getTags;
    if (fromController != null) {
      tags.addAll(fromController);
    } else {
      tags.addAll(_parseTags(tagsController.text));
    }
    tags.addAll(_parseTags(pendingTagsInput));
    final seen = <String>{};
    return tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .where((tag) => seen.add(tag.toLowerCase()))
        .toList(growable: false);
  }

  /// Сохранение задачи.
  Future<void> onSave() async {
    if (isEditingTask) {
      return;
    }
    final input = _buildInputForSaveOrNull(quiet: false);
    if (input == null) {
      return;
    }

    try {
      final task = await model.saveTask(input);
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        CreateTasksStrings.saveSuccess(context),
        messageType: SnackMessageType.success,
      );
      await context.router.maybePop(task);
    } on StateError catch (_) {
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        CreateTasksStrings.editTaskNotFound(context),
        messageType: SnackMessageType.error,
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Если «конец» не позже «начала» в тот же календарный день, переносим конец на следующий день.
  DateTime _endDateTimeWithOvernight(
    DateTime date, {
    required TimeOfDay start,
    required TimeOfDay end,
  }) {
    final startAt = _combineDateAndTime(date, start);
    var endAt = _combineDateAndTime(date, end);
    if (!endAt.isAfter(startAt)) {
      endAt = endAt.add(const Duration(days: 1));
    }
    return endAt;
  }

  /// Разбор строк материалов; при ошибке показывает подсказку и возвращает `null`.
  List<TaskMaterialRequirementEntity>? _tryParseMaterialRequirements() {
    final result = <TaskMaterialRequirementEntity>[];
    for (final row in materialRows.rows) {
      final name = row.nameController.text.trim();
      final quantityRaw = row.quantityController.text.trim().replaceAll(
        ',',
        '.',
      );
      final costRaw = row.costController.text.trim().replaceAll(',', '.');
      final rowIsEmpty = name.isEmpty && quantityRaw.isEmpty && costRaw.isEmpty;
      if (rowIsEmpty) {
        continue;
      }
      if (name.isEmpty) {
        snackController.addSnack(
          CreateTasksStrings.validationMaterialName(context),
          messageType: SnackMessageType.warning,
        );
        return null;
      }
      if (quantityRaw.isEmpty) {
        snackController.addSnack(
          CreateTasksStrings.validationMaterialQuantity(context),
          messageType: SnackMessageType.warning,
        );
        return null;
      }
      final quantity = double.tryParse(quantityRaw);
      if (quantity == null) {
        snackController.addSnack(
          CreateTasksStrings.validationMaterialQuantityFormat(context),
          messageType: SnackMessageType.warning,
        );
        return null;
      }
      if (quantity < 0) {
        snackController.addSnack(
          CreateTasksStrings.validationMaterialQuantityNegative(context),
          messageType: SnackMessageType.warning,
        );
        return null;
      }
      double lineCost = 0;
      if (costRaw.isNotEmpty) {
        final parsedCost = double.tryParse(costRaw);
        if (parsedCost == null) {
          snackController.addSnack(
            CreateTasksStrings.validationMaterialCostFormat(context),
            messageType: SnackMessageType.warning,
          );
          return null;
        }
        if (parsedCost < 0) {
          snackController.addSnack(
            CreateTasksStrings.validationMaterialCostNegative(context),
            messageType: SnackMessageType.warning,
          );
          return null;
        }
        lineCost = parsedCost;
      }
      result.add(
        TaskMaterialRequirementEntity(
          id: row.id,
          name: name,
          requiredQuantity: quantity,
          lineCost: lineCost,
          stockItemId: row.stockItemId,
        ),
      );
    }
    return result;
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(RegExp('[ ,]+'))
        .map((segment) => segment.trim())
        .map((segment) => segment.replaceAll('#', ''))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
  }

  /// Установить выбранный список после загрузки (первый по умолчанию).
  void selectDefaultListIfNeeded(List<TaskListEntity> lists) {
    if (isEditingTask) {
      return;
    }
    if (_formState.selectedListId != null) {
      return;
    }
    if (lists.isEmpty) {
      return;
    }
    _formState.setSelectedListId(lists.first.id);
  }
}
