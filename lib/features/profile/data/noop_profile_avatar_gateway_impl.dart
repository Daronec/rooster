import 'dart:typed_data';

import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';

/// Заглушка, когда облачный профиль недоступен ([AuthBackendStrategy.offlineOnly]).
final class NoopProfileAvatarGatewayImpl implements IProfileAvatarGateway {
  /// Создаёт заглушку.
  const NoopProfileAvatarGatewayImpl();

  @override
  Future<String?> getPersistedLocalAvatarPath(String userId) async => null;

  @override
  Future<void> saveAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    throw UnsupportedError('profile_avatar_unavailable_offline');
  }
}
