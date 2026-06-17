/// Статус выполнения задачи (дублируется в Realtime DB для live-индикаторов).
enum TaskStatusEntity {
  /// Активна.
  pending,

  /// Выполнена.
  completed,

  /// Отменена (не активна).
  cancelled,

  /// Отменена / архив.
  archived,
}
