import 'package:elementary/elementary.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_vk_id_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_yandex_id_gateway.dart';

/// Сценарии экрана входа.
final class AuthScreenModel extends ElementaryModel {
  /// Создаёт модель.
  AuthScreenModel({
    required IAuthGateway authGateway,
    required IVkIdGateway vkIdGateway,
    required IYandexIdGateway yandexIdGateway,
  })  : _authGateway = authGateway,
        _vkIdGateway = vkIdGateway,
        _yandexIdGateway = yandexIdGateway;

  final IAuthGateway _authGateway;
  final IVkIdGateway _vkIdGateway;
  final IYandexIdGateway _yandexIdGateway;

  /// Основной шлюз авторизации.
  IAuthGateway get authGateway => _authGateway;

  /// Шлюз VK ID.
  IVkIdGateway get vkIdGateway => _vkIdGateway;

  /// Шлюз Yandex ID.
  IYandexIdGateway get yandexIdGateway => _yandexIdGateway;

  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges =>
      _authGateway.authStateChanges;

  /// Текущий пользователь (если сессия восстановлена).
  bool get hasSession => _authGateway.currentUser != null;

  /// Ключ строки вступления на экране входа.
  String get introTranslationKey => 'auth.introSyncWithCloud';
}
