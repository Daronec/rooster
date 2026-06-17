import 'package:rooster/features/profile/domain/entities/profile_entity.dart';

/// Чтение и запись профиля в облаке (Appwrite).
abstract interface class IProfilePersonalDataGateway {
  /// Подписка на изменения (Firestore — непрерывно; HMS — одна эмиссия после загрузки).
  Stream<ProfileEntity> watchPersonalData(String userId);

  /// Разовая загрузка (например после сохранения на ветке без live-stream).
  Future<ProfileEntity> loadPersonalData(String userId);

  /// Сохранить имя и фамилию в облаке.
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName,
  });

  /// Записать [ProfileEntity.avatarId] (путь объекта в Storage), не меняя ФИО.
  Future<void> syncAvatarStorageObjectId({
    required String userId,
    required String avatarStorageObjectId,
  });
}
