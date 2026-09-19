import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';

/// Noop-реализация [ISberIdGateway] для офлайн-режима.
final class NoopSberIdGatewayImpl implements ISberIdGateway {
  /// Создаёт noop-реализацию.
  const NoopSberIdGatewayImpl();

  @override
  bool get isSberIdAvailable => false;

  @override
  Future<SberIdUserEntity?> signInWithSberId() async => null;

  @override
  void dispose() {}

  @override
  Future<void> signOut() async {}
}
