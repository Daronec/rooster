import 'dart:typed_data';

import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';

/// Noop implementation of [IProfileAvatarGateway].
///
/// Used when avatar editing is not available or not needed.
final class NoopProfileAvatarGatewayImpl implements IProfileAvatarGateway {
  /// Creates a noop implementation.
  const NoopProfileAvatarGatewayImpl();

  @override
  Future<String?> getPersistedLocalAvatarPath(String userId) async {
    return null;
  }

  @override
  Future<void> saveAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    // No-op
  }
}
