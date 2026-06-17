/// Источник имени автора для записи истории изменений задачи.
abstract interface class ITaskChangeAuthorProvider {
  /// Текущее отображаемое имя автора изменения.
  String? get currentAuthorName;
}
