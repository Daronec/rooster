import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';

/// Нет облака — только локальный просмотр заглушки, сохранение недоступно.
final class NoopProfilePersonalDataGatewayImpl
    implements IProfilePersonalDataGateway {
  /// Создаёт заглушку.
  const NoopProfilePersonalDataGatewayImpl();

  @override
  Future<ProfileEntity> loadPersonalData(String userId) async =>
      ProfileEntity(userId: userId);

  @override
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    throw UnsupportedError('profile_personal_data_unavailable_offline');
  }

  @override
  Stream<ProfileEntity> watchPersonalData(String userId) =>
      Stream<ProfileEntity>.value(ProfileEntity(userId: userId));

  @override
  Future<void> syncAvatarStorageObjectId({
    required String userId,
    required String avatarStorageObjectId,
  }) async {}
}
