/// Ключи атрибутов документов коллекций синхронизации задач в Appwrite Databases.
///
/// В консоли Appwrite для коллекций задач и списков нужно создать одноимённые
/// строковые/числовые атрибуты; `documentJson` — строка с JSON полного снимка
/// сущности (как в Hive-кодеках задач и списков).
abstract final class AppwriteSyncDocumentPayloadKeys {
  /// Идентификатор владельца ([AppAuthUserEntity.uid] / `$id` аккаунта Appwrite).
  static const String userId = 'userId';

  /// JSON-строка с полем сущности для офлайн-кодеков.
  static const String documentJson = 'documentJson';

  /// [DateTime] последнего изменения (UTC ISO 8601).
  static const String updatedAtIso = 'updatedAtIso';

  /// [TaskEntity.contentRevision] / [TaskListEntity.contentRevision].
  static const String contentRevision = 'contentRevision';

  /// Список пользователей, которым документ расшарен (доп. выборка для задач).
  static const String sharedWith = 'sharedWith';
}
