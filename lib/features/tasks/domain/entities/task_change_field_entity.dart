/// Поле задачи, которое могло измениться.
enum TaskChangeFieldEntity {
  /// Заголовок.
  title,

  /// Описание.
  description,

  /// Список.
  list,

  /// Родительская задача.
  parentTask,

  /// Исполнитель.
  executor,

  /// Наблюдатель.
  observer,

  /// Срок/дата.
  dueDate,

  /// Время (start/end).
  time,

  /// Приоритет.
  priority,

  /// Теги.
  tags,

  /// Статус выполнения.
  status,

  /// Оценочная стоимость.
  estimatedCost,

  /// Материалы.
  materials,

  /// Вложение (изображение).
  attachment,
}
