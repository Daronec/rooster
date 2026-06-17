import 'dart:typed_data';

/// Сохранение и чтение аватарки профиля (облако или локально в зависимости от бэкенда).
abstract interface class IProfileAvatarGateway {
  /// Локальный путь к файлу аватарки; иначе `null`, UI использует [AppAuthUserEntity.photoUrl].
  Future<String?> getPersistedLocalAvatarPath(String userId);

  /// Загрузить/сохранить аватар из байтов изображения (после [ImagePicker]).
  Future<void> saveAvatar({
    required String userId,
    required Uint8List imageBytes,
  });
}
