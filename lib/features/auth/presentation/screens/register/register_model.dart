import 'package:elementary/elementary.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';

/// Сценарии экрана регистрации (Appwrite).
final class RegisterScreenModel extends ElementaryModel {
  /// Создаёт модель.
  RegisterScreenModel({required IAuthGateway authGateway})
    : _authGateway = authGateway;

  final IAuthGateway _authGateway;

  /// Поток смены пользователя (после успешной регистрации).
  Stream<AppAuthUserEntity?> get authStateChanges =>
      _authGateway.authStateChanges;

  /// Есть ли уже сессия.
  bool get hasSession => _authGateway.currentUser != null;

  /// Регистрация с профилем.
  Future<void> signUpWithProfile({
    required String email,
    required String password,
    required String name,
    required String phoneE164,
  }) =>
      _authGateway.signUpWithEmailPasswordProfile(
        email: email,
        password: password,
        name: name,
        phoneE164: phoneE164,
      );
}
