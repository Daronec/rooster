import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';

/// Запись истории изменений одной задачи.
final class TaskChangeEntity {
  /// Создаёт запись.
  const TaskChangeEntity({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.changedAtMillis,
    required this.changedFields,
    required this.taskTitleSnapshot,
    required this.authorNameSnapshot,
  });

  /// Уникальный id записи (UUID).
  final String id;

  /// Id задачи.
  final String taskId;

  /// Тип изменения.
  final TaskChangeKindEntity kind;

  /// Время события (epoch ms).
  final int changedAtMillis;

  /// Список изменённых полей (для updated; для created/deleted может быть пустым).
  final List<TaskChangeFieldEntity> changedFields;

  /// Заголовок задачи на момент события (для удобного отображения, даже если задача удалена).
  final String taskTitleSnapshot;

  /// Имя автора изменения на момент события.
  final String authorNameSnapshot;
}
