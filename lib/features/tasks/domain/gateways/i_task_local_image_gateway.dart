/// Сохранение файла изображения, выбранного пользователем, в постоянное хранилище приложения.
abstract interface class ITaskLocalImageGateway {
  /// Копирует [sourcePath] в каталог данных приложения; возвращает новый путь.
  ///
  /// На вебе может вернуть исходный путь, если копирование недоступно.
  Future<String> persistPickerFile(
    String sourcePath, {
    required String taskId,
  });
}
