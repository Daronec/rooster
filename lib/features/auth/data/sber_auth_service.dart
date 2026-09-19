import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Результат авторизации через Sber ID.
sealed class SberAuthResult {
  const SberAuthResult();
}

/// Успешная авторизация — получен authorization code.
class SberAuthSuccess extends SberAuthResult {
  const SberAuthSuccess(this.code);
  final String code;
}

/// Ошибка авторизации.
class SberAuthFailure extends SberAuthResult {
  const SberAuthFailure(this.error, this.message);
  final String error;
  final String message;
}

/// Сервис авторизации через нативный SDK / OAuth Sber ID.
///
/// Использует MethodChannel для вызова нативных методов и получения событий.
///
/// Flow:
/// 1. Flutter вызывает `initialize()` — передаёт CLIENT_ID из .env в нативную часть
/// 2. Flutter вызывает `startLogin()` — нативная часть открывает браузер/приложение Сбера
/// 3. После авторизации Сбер редиректит на `rooster-auth://sber-id?code=...`
/// 4. Нативная часть извлекает `code` и отправляет событие `onSberAuthSuccess` во Flutter
/// 5. Flutter обменивает code на токен на бэкенде
class SberAuthService {
  static const MethodChannel _channel = MethodChannel('com.rooster.app/sber_auth');

  Stream<SberAuthResult>? _authStream;

  /// Получить stream событий авторизации.
  Stream<SberAuthResult> get authStream {
    _authStream ??= _createAuthStream();
    return _authStream!;
  }

  Stream<SberAuthResult> _createAuthStream() {
    return _channel.receiveBroadcastStream('authEvents').map((dynamic event) {
      if (event == null) return const SberAuthFailure('unknown', 'No event data');

      if (event is Map) {
        final method = event['method'] as String?;
        final arguments = event['arguments'] as Map<String, dynamic>? ?? {};

        switch (method) {
          case 'onSberAuthSuccess':
            final code = arguments['code'] as String?;
            if (code != null) {
              return SberAuthSuccess(code);
            }
            return const SberAuthFailure('invalid_response', 'Missing code in success event');
          case 'onSberAuthError':
            final error = arguments['error'] as String? ?? 'unknown';
            final message = arguments['message'] as String? ?? 'Authorization failed';
            return SberAuthFailure(error, message);
          default:
            debugPrint('SberAuthService: unknown event method: $method');
            return const SberAuthFailure('unknown_event', 'Unknown event: $method');
        }
      }

      return const SberAuthFailure('invalid_format', 'Invalid event format');
    });
  }

  /// Инициализировать SDK — передать CLIENT_ID из .env в нативную часть.
  ///
  /// Вызывается один раз при старте приложения или при инициализации DI.
  Future<void> initialize() async {
    try {
      final clientId = dotenv.env['SBER_CLIENT_ID'] ?? '';
      if (clientId.isEmpty) {
        debugPrint('SberAuthService: SBER_CLIENT_ID is empty in .env');
        return;
      }

      debugPrint('SberAuthService: initializing with clientId: $clientId');
      await _channel.invokeMethod('initSberSdk', {
        'clientId': clientId,
        'scope': 'openid profile',
      });
    } catch (e) {
      debugPrint('SberAuthService: initialization error: $e');
      // Инициализация не критична — CLIENT_ID также берётся из manifest/Info.plist
    }
  }

  /// Выполнить вход через Sber ID.
  ///
  /// Открывает браузер или приложение СберБанк Онлайн для авторизации.
  /// Результат приходит через [authStream].
  Future<bool> startLogin() async {
    try {
      debugPrint('SberAuthService: starting Sber ID login...');
      final bool? success = await _channel.invokeMethod('startLogin');
      return success == true;
    } on PlatformException catch (e) {
      debugPrint('SberAuthService: platform error during login: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('SberAuthService: unexpected error during login: $e');
      return false;
    }
  }

  /// Проверить, доступен ли нативный SDK Сбер ID.
  Future<bool> isSberIdAvailable() async {
    try {
      final bool? available = await _channel.invokeMethod('isAvailable');
      return available == true;
    } catch (_) {
      return false;
    }
  }

  /// Закрыть stream при уничтожении сервиса.
  void dispose() {
    _authStream = null;
  }
}
