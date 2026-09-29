import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для аутентификации через Sber ID + cloud.ru.
///
/// Flow:
/// 1. Sber ID OAuth2 → code
/// 2. Exchange code for Yandex IAM token via cloud.ru backend
/// 3. Store IAM token in secure storage
/// 4. Use IAM token for all API calls
class CloudRuAuthService {
  /// Создаёт сервис.
  CloudRuAuthService({
    required String tokenExchangeEndpoint,
    required ILogWriter logger,
    required FlutterSecureStorage secureStorage,
  })  : _tokenExchangeEndpoint = tokenExchangeEndpoint,
        _logger = logger,
        _secureStorage = secureStorage,
        _dio = Dio();

  final String _tokenExchangeEndpoint;
  final ILogWriter _logger;
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  String? _cachedIamToken;

  /// Текущий IAM token.
  String? get iamToken => _cachedIamToken;

  /// Получить IAM token из secure storage.
  Future<String?> _getStoredIamToken() async {
    try {
      return await _secureStorage.read(key: 'iam_token');
    } on Exception catch (e) {
      _logger.log('cloud_ru_get_stored_token_error: $e');
      return null;
    }
  }

  /// Сохранить IAM token в secure storage.
  Future<void> _storeIamToken(String token) async {
    try {
      await _secureStorage.write(key: 'iam_token', value: token);
      _cachedIamToken = token;
    } on Exception catch (e) {
      _logger.log('cloud_ru_store_token_error: $e');
    }
  }

  /// Очистить сохранённый token.
  Future<void> _clearStoredToken() async {
    try {
      await _secureStorage.delete(key: 'iam_token');
      _cachedIamToken = null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_clear_token_error: $e');
    }
  }

  /// Обменять Sber ID code на Yandex IAM token.
  ///
  /// Отправляет Sber ID authorization code на cloud.ru backend,
  /// который валидирует его и возвращает Yandex IAM token.
  Future<String?> exchangeSberIdCodeForToken(String sberIdCode) async {
    try {
      debugPrint('CloudRuAuthService: exchanging Sber ID code for IAM token...');
      
      final response = await _dio.post<Map<String, dynamic>>(
        _tokenExchangeEndpoint,
        data: {'sber_id_code': sberIdCode},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data ?? {};
        final iamToken = data['iam_token'] as String?;
        
        if (iamToken != null && iamToken.isNotEmpty) {
          await _storeIamToken(iamToken);
          debugPrint('CloudRuAuthService: IAM token obtained successfully');
          return iamToken;
        }
        
        _logger.log('cloud_ru_exchange_token_error: no iam_token in response');
        return null;
      }
      
      _logger.log('cloud_ru_exchange_token_error: status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      _logger.log('cloud_ru_exchange_token_dio_error: ${e.message}');
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_exchange_token_error: $e');
      return null;
    }
  }

  /// Обновить IAM token (refresh).
  Future<String?> refreshIamToken() async {
    try {
      debugPrint('CloudRuAuthService: refreshing IAM token...');
      
      final storedToken = await _getStoredIamToken();
      if (storedToken == null) {
        debugPrint('CloudRuAuthService: no stored token to refresh');
        return null;
      }
      
      // TODO(cloud.ru): Implement token refresh logic
      // This depends on cloud.ru backend refresh endpoint
      
      _logger.log('cloud_ru_refresh_token_not_implemented');
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_refresh_token_error: $e');
      return null;
    }
  }

  /// Выйти из сессии (очистить token).
  Future<void> signOut() async {
    await _clearStoredToken();
    debugPrint('CloudRuAuthService: signed out');
  }
}
