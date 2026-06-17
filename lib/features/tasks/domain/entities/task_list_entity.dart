/// Список задач (проект / колонка Notion-lite).
final class TaskListEntity {
  /// Создаёт список.
  const TaskListEntity({
    required this.id,
    required this.name,
    required this.colorArgb,
    required this.updatedAtMillis, this.contentRevision = 0,
  });

  /// Id списка.
  final String id;

  /// Отображаемое имя.
  final String name;

  /// Цвет в формате 0xAARRGGBB.
  final int colorArgb;

  /// Ревизия для разрешения конфликтов.
  final int contentRevision;

  /// Время изменения (epoch ms).
  final int updatedAtMillis;

  /// Копия с заменой полей.
  TaskListEntity copyWith({
    String? name,
    int? colorArgb,
    int? contentRevision,
    int? updatedAtMillis,
  }) {
    return TaskListEntity(
      id: id,
      name: name ?? this.name,
      colorArgb: colorArgb ?? this.colorArgb,
      contentRevision: contentRevision ?? this.contentRevision,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }
}
