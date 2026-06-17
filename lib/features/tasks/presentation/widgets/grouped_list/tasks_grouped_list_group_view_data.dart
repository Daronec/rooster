import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Данные одной группы задач (один список) для отображения.
final class TasksGroupedListGroupViewData {
  /// Создаёт данные группы.
  const TasksGroupedListGroupViewData({
    required this.listId,
    required this.title,
    required this.colorArgb,
    required this.tasks,
  });

  /// Id списка.
  final String listId;

  /// Заголовок группы.
  final String title;

  /// Цвет маркера группы (ARGB).
  final int colorArgb;

  /// Задачи в группе.
  final List<TaskEntity> tasks;
}

