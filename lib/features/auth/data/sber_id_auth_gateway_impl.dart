import 'package:flutter/foundation.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';

/// Реализация [ISberIdGateway] через Appwrite OAuth2 (cloud.ru).
///
/// Использует [IAuthGateway.signInWithSberId()] который вызывает
/// Appwrite `createOAuth2Session(provider: .custom)` — Appwrite сам
/// обменивает authorization code на сессию.
final class SberIdAuthGatewayImpl implements ISberIdGateway {
  SberIdAuthGatewayImpl({
    required IAuthGateway authGateway,
  }) : _authGateway = authGateway;

  final IAuthGateway _authGateway;

  @override
  bool get isSberIdAvailable => true;

  @override
  Future<void> signInWithSberId() async {
    try {
      debugPrint('SberIdAuthGatewayImpl: starting Sber ID via Appwrite OAuth2...');
      await _authGateway.signInWithSberId();
      debugPrint('SberIdAuthGatewayImpl: Sber ID sign-in completed');
    } on Object catch (e) {
      debugPrint('SberIdAuthGatewayImpl: Sber ID sign-in failed: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    // Нет ресурсов для освобождения
  }
}
