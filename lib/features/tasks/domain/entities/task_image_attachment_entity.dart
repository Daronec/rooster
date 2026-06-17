/// Вложение изображения к задаче (локальный файл + опциональный URL после синка).
final class TaskImageAttachmentEntity {
  /// Создаёт вложение.
  const TaskImageAttachmentEntity({
    required this.localPath,
    this.remoteUrl,
  });

  /// Локальный путь к изображению (в хранилище приложения или временный путь picker).
  final String localPath;

  /// URL в облачном хранилище после синхронизации (если поддерживается).
  final String? remoteUrl;

  /// Копия с заменой полей.
  TaskImageAttachmentEntity copyWith({
    String? localPath,
    String? remoteUrl,
  }) {
    return TaskImageAttachmentEntity(
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }
}

