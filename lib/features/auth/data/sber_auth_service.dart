import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Сервис авторизации через нативный SDK Сбер ID.
class SberAuthService {
  static const MethodChannel _channel = MethodChannel('sber_id_auth');

  /// Выполнить вход через нативное приложение Сбера.
  ///
  /// Возвращает access-token при успехе, null при отмене или ошибке.
  Future<String?> loginWithSber() async {
    try {
      debugPrint('SberAuthService: initiating login with Sber ID...');

      final String? token = await _channel.invokeMethod('loginWithSber');

      if (token != null && token.isNotEmpty) {
        debugPrint('SberAuthService: token received (length: ${token.length})');
        return token;
      }

      debugPrint('SberAuthService: no token received');
      return null;
    } on PlatformException catch (e) {
      _handlePlatformException(e);
      return null;
    } catch (e) {
      debugPrint('SberAuthService: unexpected error: $e');
      return null;
    }
  }

  /// Проверить, доступен ли нативный SDK Сбер ID.
  Future<bool> isSberIdAvailable() async {
    try {
      final bool? available = await _channel.invokeMethod('isAvailable');
      return available ?? false;
    } catch (_) {
      return false;
    }
  }

  void _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'SBER_ID_CANCELLED':
        debugPrint('SberAuthService: user cancelled authorization');
        break;
      case 'SBER_ID_ERROR':
        debugPrint('SberAuthService: Sber ID error: ${e.message}');
        break;
      default:
        debugPrint('SberAuthService: platform error: ${e.message}');
        break;
    }
  }
}
