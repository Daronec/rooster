import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';

/// Noop implementation of [IProfilePersonalDataGateway].
///
/// Used when profile personal data editing is not available or not needed.
final class NoopProfilePersonalDataGatewayImpl
    implements IProfilePersonalDataGateway {
  /// Creates a noop implementation.
  const NoopProfilePersonalDataGatewayImpl();

  @override
  Stream<ProfileEntity> watchPersonalData(String userId) {
    return const Stream.empty();
  }

  @override
  Future<ProfileEntity> loadPersonalData(String userId) async {
    throw UnimplementedError('Noop implementation');
  }

  @override
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    // No-op
  }

  @override
  Future<void> syncAvatarStorageObjectId({
    required String userId,
    required String avatarStorageObjectId,
  }) async {
    // No-op
  }
}
