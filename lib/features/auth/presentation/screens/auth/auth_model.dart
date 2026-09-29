import 'package:elementary/elementary.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';

/// Сценарии экрана входа.
final class AuthScreenModel extends ElementaryModel {
  /// Создаёт модель.
  AuthScreenModel({
    required IAuthGateway authGateway,
  }) : _authGateway = authGateway;

  final IAuthGateway _authGateway;

  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges =>
      _authGateway.authStateChanges;

  /// Текущий пользователь (если сессия восстановлена).
  bool get hasSession => _authGateway.currentUser != null;

  /// Ключ строки вступления на экране входа.
  String get introTranslationKey => 'auth.introSberId';
}
