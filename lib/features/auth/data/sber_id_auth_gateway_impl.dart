import 'package:flutter/foundation.dart';
import 'package:rooster/features/auth/data/sber_auth_service.dart';
import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';

/// Реализация [ISberIdGateway] через нативный SDK Сбер ID.
final class SberIdAuthGatewayImpl implements ISberIdGateway {
  SberIdAuthGatewayImpl({
    required SberAuthService sberAuthService,
  }) : _sberAuthService = sberAuthService;

  final SberAuthService _sberAuthService;

  @override
  bool get isSberIdAvailable => true;

  @override
  Future<SberIdUserEntity?> signInWithSberId() async {
    try {
      debugPrint('SberIdAuthGatewayImpl: initiating sign in with Sber ID...');

      final token = await _sberAuthService.loginWithSber();

      if (token == null) {
        debugPrint('SberIdAuthGatewayImpl: no token received');
        return null;
      }

      // TODO: Отправить токен на Backend для получения данных пользователя
      // В реальном проекте здесь будет вызов API вашего бэкенда
      // final userData = await _backend.getUserBySberToken(token);

      // Возвращаем mock-данные для демонстрации
      // В реальности данные придут с бэкенда после валидации токена
      final user = SberIdUserEntity(
        id: 'sber_user_${DateTime.now().millisecondsSinceEpoch}',
        email: null, // Получится с бэкенда
        displayName: null, // Получится с бэкенда
        phone: null, // Получится с бэкенда
        accessToken: token,
        refreshToken: null,
      );

      debugPrint('SberIdAuthGatewayImpl: user signed in successfully');
      return user;
    } on Object catch (e) {
      debugPrint('SberIdAuthGatewayImpl: sign in failed: $e');
      return null;
    }
  }
}
