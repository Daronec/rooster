import 'package:elementary/elementary.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rooster/features/auth/data/services/social_auth_service.dart';
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
    required SocialAuthService socialAuthService,
  })  : _authGateway = authGateway,
        _vkIdGateway = vkIdGateway,
        _yandexIdGateway = yandexIdGateway,
        _socialAuthService = socialAuthService;

  final IAuthGateway _authGateway;
  final IVkIdGateway _vkIdGateway;
  final IYandexIdGateway _yandexIdGateway;
  final SocialAuthService _socialAuthService;

  /// Основной шлюз авторизации.
  IAuthGateway get authGateway => _authGateway;

  /// Шлюз VK ID.
  IVkIdGateway get vkIdGateway => _vkIdGateway;

  /// Шлюз Yandex ID.
  IYandexIdGateway get yandexIdGateway => _yandexIdGateway;

  /// Social auth facade for sign-in flows.
  SocialAuthService get socialAuthService => _socialAuthService;

  /// Объединённый поток смены пользователя от всех social auth gateway.
  Stream<AppAuthUserEntity?> get authStateChanges =>
      MergeStream([
        _authGateway.authStateChanges,
        _yandexIdGateway.authStateChanges,
      ]);

  /// Текущий пользователь (если сессия восстановлена).
  bool get hasSession =>
      _authGateway.currentUser != null ||
      _yandexIdGateway.currentUser != null;

  /// Ключ строки вступления на экране входа.
  String get introTranslationKey => 'auth.introSyncWithCloud';

  /// Вход через VK ID.
  Future<void> signInWithVkId() async {
    await _vkIdGateway.signInWithVkId();
  }

  /// Вход через Yandex ID.
  Future<void> signInWithYandexId() async {
    await _yandexIdGateway.signInWithYandexId();
  }
}
