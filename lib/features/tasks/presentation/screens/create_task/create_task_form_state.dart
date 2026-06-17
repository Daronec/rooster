import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/domain/entities/task_creation_input_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';

/// Изменяемое состояние формы создания задачи (без текстовых полей — они в [TextEditingController] WM).
///
/// Один [ChangeNotifier] снижает число подписок по сравнению с десятком [ValueNotifier].
final class CreateTaskFormState extends ChangeNotifier {
  /// Создаёт состояние с начальными значениями.
  CreateTaskFormState() {
    final now = DateTime.now();
    _dueDate = DateTime(now.year, now.month, now.day);
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 10, minute: 0);
    _recurrenceTime = const TimeOfDay(hour: 9, minute: 0);
  }

  String? _selectedListId;

  /// Выбранный список задач.
  String? get selectedListId => _selectedListId;

  /// Слушатель выбранного списка (для UI-компонентов на [ValueListenable]).
  final ValueNotifier<String?> selectedListIdListenable =
      ValueNotifier<String?>(null);

  /// Установить список.
  void setSelectedListId(String? value) {
    if (_selectedListId == value) {
      return;
    }
    _selectedListId = value;
    selectedListIdListenable.value = value;
    notifyListeners();
  }

  String? _parentTaskId;
  List<String> _dependencyTaskIds = const [];

  /// Id родительской задачи (если создаём/редактируем подзадачу).
  String? get parentTaskId => _parentTaskId;

  /// Id задач, от которых зависит текущая задача.
  List<String> get dependencyTaskIds => _dependencyTaskIds;

  /// Установить родительскую задачу.
  void setParentTaskId(String? value) {
    if (_parentTaskId == value) {
      return;
    }
    _parentTaskId = value;
    notifyListeners();
  }

  /// Установить зависимости задачи.
  void setDependencyTaskIds(Iterable<String> value) {
    final next = _normalizeTaskIds(value);
    if (_listEquals(_dependencyTaskIds, next)) {
      return;
    }
    _dependencyTaskIds = next;
    notifyListeners();
  }

  List<String> _normalizeTaskIds(Iterable<String> ids) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final rawId in ids) {
      final id = rawId.trim();
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      normalized.add(id);
    }
    return List<String>.unmodifiable(normalized);
  }

  bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  String? _executorUserId;
  String? _executorTeamId;
  String? _observerUserId;
  String? _observerTeamId;

  /// Id выбранного исполнителя из команд Appwrite.
  String? get executorUserId => _executorUserId;

  /// Id команды Appwrite, из которой выбран исполнитель.
  String? get executorTeamId => _executorTeamId;

  /// Id выбранного наблюдателя из команд Appwrite.
  String? get observerUserId => _observerUserId;

  /// Id команды Appwrite, из которой выбран наблюдатель.
  String? get observerTeamId => _observerTeamId;

  /// Слушатель выбранного исполнителя (для UI-компонентов на [ValueListenable]).
  final ValueNotifier<String?> executorSelectionListenable =
      ValueNotifier<String?>(null);

  /// Слушатель выбранного наблюдателя (для UI-компонентов на [ValueListenable]).
  final ValueNotifier<String?> observerSelectionListenable =
      ValueNotifier<String?>(null);

  /// Установить исполнителя (значение из dropdown): `<teamId>:<userId>`.
  void setExecutorSelectionId(String? value) {
    final selection = _parseRoleSelection(value, roleName: 'executor');
    if (selection == null) {
      return;
    }
    final changed =
        _executorTeamId != selection.teamId ||
        _executorUserId != selection.userId;
    _executorTeamId = selection.teamId;
    _executorUserId = selection.userId;
    executorSelectionListenable.value = selection.value;
    if (changed) {
      notifyListeners();
    }
  }

  /// Установить наблюдателя (значение из dropdown): `<teamId>:<userId>`.
  void setObserverSelectionId(String? value) {
    final selection = _parseRoleSelection(value, roleName: 'observer');
    if (selection == null) {
      return;
    }
    final changed =
        _observerTeamId != selection.teamId ||
        _observerUserId != selection.userId;
    _observerTeamId = selection.teamId;
    _observerUserId = selection.userId;
    observerSelectionListenable.value = selection.value;
    if (changed) {
      notifyListeners();
    }
  }

  _RoleSelection? _parseRoleSelection(
    String? value, {
    required String roleName,
  }) {
    final trimmed = value?.trim() ?? '';
    if (kDebugMode) {
      debugPrint('create_task_${roleName}_changed raw=$value trimmed=$trimmed');
    }
    if (trimmed.isEmpty) {
      return const _RoleSelection.empty();
    }
    final separatorIndex = trimmed.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex >= trimmed.length - 1) {
      if (kDebugMode) {
        debugPrint('create_task_${roleName}_parse_skip trimmed=$trimmed');
      }
      return null;
    }
    final teamId = trimmed.substring(0, separatorIndex).trim();
    final userId = trimmed.substring(separatorIndex + 1).trim();
    if (teamId.isEmpty || userId.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'create_task_${roleName}_parse_empty teamId=$teamId userId=$userId',
        );
      }
      return null;
    }
    return _RoleSelection(teamId: teamId, userId: userId, value: trimmed);
  }

  late DateTime _dueDate;

  /// Дата срока / дата интервала исполнения.
  DateTime get dueDate => _dueDate;

  /// Установить дату.
  void setDueDate(DateTime value) {
    _dueDate = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }

  bool _isAllDay = true;

  /// Режим «весь день».
  bool get isAllDay => _isAllDay;

  /// Переключить «весь день».
  void setAllDay(bool value) {
    if (_isAllDay == value) {
      return;
    }
    _isAllDay = value;
    notifyListeners();
  }

  late TimeOfDay _startTime;

  /// Время начала (если не [isAllDay]).
  TimeOfDay get startTime => _startTime;

  /// Установить время начала.
  void setStartTime(TimeOfDay value) {
    _startTime = value;
    notifyListeners();
  }

  late TimeOfDay _endTime;

  /// Время окончания (если не [isAllDay]).
  TimeOfDay get endTime => _endTime;

  /// Установить время окончания.
  void setEndTime(TimeOfDay value) {
    _endTime = value;
    notifyListeners();
  }

  TaskReminderPresetEntity _reminderPreset = TaskReminderPresetEntity.none;

  /// Пресет напоминания.
  TaskReminderPresetEntity get reminderPreset => _reminderPreset;

  /// Слушатель пресета напоминания (как `enum.name`).
  final ValueNotifier<String?> reminderPresetListenable =
      ValueNotifier<String?>(TaskReminderPresetEntity.none.name);

  /// Установить пресет напоминания.
  void setReminderPreset(TaskReminderPresetEntity value) {
    if (_reminderPreset == value) {
      return;
    }
    _reminderPreset = value;
    reminderPresetListenable.value = value.name;
    notifyListeners();
  }

  DateTime? _customReminderAt;

  /// Дата/время для пресета [TaskReminderPresetEntity.custom].
  DateTime? get customReminderAt => _customReminderAt;

  /// Установить произвольное напоминание.
  void setCustomReminderAt(DateTime? value) {
    _customReminderAt = value;
    notifyListeners();
  }

  int _recurrenceWeekdaysMask = 0;

  /// Маска дней недели для постоянного напоминания.
  int get recurrenceWeekdaysMask => _recurrenceWeekdaysMask;

  /// Установить маску дней.
  void setRecurrenceWeekdaysMask(int value) {
    if (_recurrenceWeekdaysMask == value) {
      return;
    }
    _recurrenceWeekdaysMask = value;
    notifyListeners();
  }

  late TimeOfDay _recurrenceTime;

  /// Время постоянного напоминания.
  TimeOfDay get recurrenceTime => _recurrenceTime;

  /// Установить время постоянного напоминания.
  void setRecurrenceTime(TimeOfDay value) {
    _recurrenceTime = value;
    notifyListeners();
  }

  int _importance = 3;

  /// Важность 1–5.
  int get importance => _importance;

  /// Слушатель важности (как строка числа 1–5).
  final ValueNotifier<String?> importanceListenable = ValueNotifier<String?>(
    '3',
  );

  /// Установить важность.
  void setImportance(int value) {
    final clamped = value.clamp(1, 5);
    if (_importance == clamped) {
      return;
    }
    _importance = clamped;
    importanceListenable.value = clamped.toString();
    notifyListeners();
  }

  int _complexity = 3;

  /// Сложность 1–5.
  int get complexity => _complexity;

  /// Слушатель сложности (как строка числа 1–5).
  final ValueNotifier<String?> complexityListenable = ValueNotifier<String?>(
    '3',
  );

  /// Установить сложность.
  void setComplexity(int value) {
    final clamped = value.clamp(1, 5);
    if (_complexity == clamped) {
      return;
    }
    _complexity = clamped;
    complexityListenable.value = clamped.toString();
    notifyListeners();
  }

  TaskPriorityEntity _priority = TaskPriorityEntity.normal;

  /// Приоритет.
  TaskPriorityEntity get priority => _priority;

  /// Слушатель приоритета (как `enum.name`).
  final ValueNotifier<String?> priorityListenable = ValueNotifier<String?>(
    TaskPriorityEntity.normal.name,
  );

  /// Установить приоритет.
  void setPriority(TaskPriorityEntity value) {
    if (_priority == value) {
      return;
    }
    _priority = value;
    priorityListenable.value = value.name;
    notifyListeners();
  }

  List<TaskImageAttachmentEntity> _imageAttachments = const [];

  /// Изображения, прикреплённые к задаче.
  List<TaskImageAttachmentEntity> get imageAttachments => _imageAttachments;

  /// Установить список изображений.
  void setImageAttachments(List<TaskImageAttachmentEntity> value) {
    _imageAttachments = List<TaskImageAttachmentEntity>.unmodifiable(value);
    notifyListeners();
  }

  /// Добавить изображения по локальным путям (дубликаты игнорируются).
  void addImageLocalPaths(Iterable<String> paths) {
    final existing = <String>{};
    for (final item in _imageAttachments) {
      if (item.localPath.isNotEmpty) {
        existing.add(item.localPath);
      }
    }
    final next = <TaskImageAttachmentEntity>[..._imageAttachments];
    for (final raw in paths) {
      final path = raw.trim();
      if (path.isEmpty || existing.contains(path)) {
        continue;
      }
      next.add(TaskImageAttachmentEntity(localPath: path));
      existing.add(path);
    }
    setImageAttachments(next);
  }

  /// Удалить изображение по индексу.
  void removeImageAt(int index) {
    if (index < 0 || index >= _imageAttachments.length) {
      return;
    }
    final next = <TaskImageAttachmentEntity>[..._imageAttachments]
      ..removeAt(index);
    setImageAttachments(next);
  }

  /// Заполняет поля из доменного снимка (режим редактирования); одно уведомление слушателей.
  void hydrateFromCreationInput(TaskCreationInputEntity input) {
    _selectedListId = input.listId;
    selectedListIdListenable.value = input.listId;
    _parentTaskId = input.parentTaskId;
    _dependencyTaskIds = _normalizeTaskIds(input.dependencyTaskIds);
    _executorUserId = input.executorUserId;
    _executorTeamId = input.executorTeamId;
    executorSelectionListenable.value =
        _executorTeamId == null || _executorUserId == null
        ? null
        : '${_executorTeamId!}:${_executorUserId!}';
    _observerUserId = input.observerUserId;
    _observerTeamId = input.observerTeamId;
    observerSelectionListenable.value =
        _observerTeamId == null || _observerUserId == null
        ? null
        : '${_observerTeamId!}:${_observerUserId!}';
    _reminderPreset = input.reminderPreset;
    reminderPresetListenable.value = input.reminderPreset.name;
    _customReminderAt = input.customReminderAt;
    _recurrenceWeekdaysMask = input.recurrenceWeekdaysMask;
    _importance = input.importance.clamp(1, 5);
    importanceListenable.value = _importance.toString();
    _complexity = input.complexity.clamp(1, 5);
    complexityListenable.value = _complexity.toString();
    _priority = input.priority;
    priorityListenable.value = input.priority.name;
    _imageAttachments = List<TaskImageAttachmentEntity>.unmodifiable(
      input.imageAttachments,
    );
    _isAllDay = input.isAllDay;

    if (input.isAllDay) {
      if (input.dueDateOnly != null) {
        _dueDate = DateTime(
          input.dueDateOnly!.year,
          input.dueDateOnly!.month,
          input.dueDateOnly!.day,
        );
      }
    } else {
      final start = input.startAt;
      final end = input.endAt;
      final anchor = start ?? end ?? input.dueDateOnly ?? DateTime.now();
      _dueDate = DateTime(anchor.year, anchor.month, anchor.day);
      if (start != null) {
        _startTime = TimeOfDay.fromDateTime(start);
      }
      if (end != null) {
        _endTime = TimeOfDay.fromDateTime(end);
      }
    }

    final recurrenceMinutes = input.recurrenceReminderMinutesFromMidnight;
    if (recurrenceMinutes != null) {
      _recurrenceTime = TimeOfDay(
        hour: recurrenceMinutes ~/ 60,
        minute: recurrenceMinutes % 60,
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    selectedListIdListenable.dispose();
    executorSelectionListenable.dispose();
    observerSelectionListenable.dispose();
    reminderPresetListenable.dispose();
    importanceListenable.dispose();
    complexityListenable.dispose();
    priorityListenable.dispose();
    super.dispose();
  }
}

final class _RoleSelection {
  const _RoleSelection({
    required this.teamId,
    required this.userId,
    required this.value,
  });

  const _RoleSelection.empty() : teamId = null, userId = null, value = null;

  final String? teamId;

  final String? userId;

  final String? value;
}
