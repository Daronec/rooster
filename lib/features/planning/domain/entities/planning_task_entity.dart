/// Задача внутри плана.
final class PlanningTaskEntity {
  /// Создаёт задачу плана.
  const PlanningTaskEntity({
    required this.id,
    required this.title,
    required this.order,
    required this.importance,
    required this.isCompleted,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });

  /// Идентификатор задачи плана.
  final String id;

  /// Название задачи.
  final String title;

  /// Порядок выполнения внутри плана.
  final int order;

  /// Важность задачи от 1 до 5.
  final int importance;

  /// Выполнена ли задача.
  final bool isCompleted;

  /// Время создания.
  final int createdAtMillis;

  /// Время последнего изменения.
  final int updatedAtMillis;

  /// Копия с заменой полей.
  PlanningTaskEntity copyWith({
    String? id,
    String? title,
    int? order,
    int? importance,
    bool? isCompleted,
    int? createdAtMillis,
    int? updatedAtMillis,
  }) {
    return PlanningTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      order: order ?? this.order,
      importance: importance ?? this.importance,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }
}
