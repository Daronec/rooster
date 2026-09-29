import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/cloud_ru/auth/cloud_ru_auth_service.dart';

/// Реализация [ISberIdGateway] и [IAuthGateway] для Sber ID + cloud.ru.
///
/// Flow:
/// 1. Пользователь нажимает "Войти через Sber ID"
/// 2. Запускается Sber ID OAuth2 флоу (нативное приложение или браузер)
/// 3. Получаем authorization code
/// 4. Обмениваем code на Yandex IAM token через cloud.ru backend
/// 5. Сохраняем IAM token в secure storage
/// 6. Загружаем профиль пользователя с cloud.ru
/// 7. Эмитим пользователя в authStateChanges stream
final class SberIdAuthGatewayImpl
    with ChangeNotifier
    implements ISberIdGateway, IAuthGateway {
  /// Создаёт gateway.
  SberIdAuthGatewayImpl({
    required CloudRuAuthService cloudRuAuthService,
    required CloudRuClient cloudRuClient,
    required ILogWriter logger,
  })  : _cloudRuAuthService = cloudRuAuthService,
        _cloudRuClient = cloudRuClient,
        _logger = logger {
    // Восстанавливаем сессию при инициализации
    unawaited(_restoreSessionIfStored());
  }

  final CloudRuAuthService _cloudRuAuthService;
  final CloudRuClient _cloudRuClient;
  final ILogWriter _logger;

  final BehaviorSubject<AppAuthUserEntity?> _subject =
      BehaviorSubject<AppAuthUserEntity?>.seeded(null);

  AppAuthUserEntity? _currentUser;

  @override
  bool get isSberIdAvailable => true;

  @override
  Stream<AppAuthUserEntity?> get authStateChanges => _subject.stream;

  @override
  AppAuthUserEntity? get currentUser => _currentUser;

  @override
  Future<void> signInWithSberId() async {
    try {
      _logger.log('sber_id_auth_start');
      debugPrint('SberIdAuthGatewayImpl: starting Sber ID OAuth...');

      // TODO(aronets): Implement Sber ID OAuth2 flow (native app or browser)
      // Это зависит от того, как именно запускается Sber ID SDK
      // Например: await SberIdSdk.startOAuth();
      
      // Для примера показываем заглушку:
      // В реальности нужно:
      // 1. Запустить Sber ID OAuth
      // 2. Получить code из callback
      // 3. Обменять code на IAM token
      // 4. Загрузить профиль
      
      debugPrint('SberIdAuthGatewayImpl: Sber ID OAuth flow would start here');
      _logger.log('sber_id_auth_complete');
    } on Exception catch (e) {
      _logger.log('sber_id_auth_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.log('sber_id_auth_signout');
      await _cloudRuAuthService.signOut();
      _subject.add(null);
      _currentUser = null;
      notifyListeners();
    } on Exception catch (e) {
      _logger.log('sber_id_auth_signout_error: $e');
    }
  }

  @override
  void dispose() {
    _subject.close();
    super.dispose();
  }

  /// Восстановить сессию из secure storage.
  Future<void> _restoreSessionIfStored() async {
    try {
      final iamToken = _cloudRuAuthService.iamToken;
      if (iamToken == null || iamToken.isEmpty) {
        debugPrint('SberIdAuthGatewayImpl: no stored IAM token');
        return;
      }

      _logger.log('sber_id_auth_session_restore_start');

      // Обновить token в cloud.ru client
      _cloudRuClient.updateIamToken(iamToken);

      // Загрузить профиль пользователя
      final profile = await _cloudRuClient.fetchProfile();
      if (profile != null) {
        final displayName = profile['display_name'] as String? ?? '';
        final email = profile['email'] as String? ?? '';
        
        _currentUser = AppAuthUserEntity(
          uid: profile['user_id'] as String? ?? '',
          email: email.isEmpty ? null : email,
          displayName: displayName.isEmpty ? null : displayName,
          isAnonymous: false,
        );
        
        _subject.add(_currentUser);
        _logger.log('sber_id_auth_session_restored_ok');
      }
    } on Exception catch (e) {
      _logger.log('sber_id_auth_session_restore_error: $e');
    }
  }

}
