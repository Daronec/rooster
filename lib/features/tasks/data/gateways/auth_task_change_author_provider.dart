import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_change_author_provider.dart';

/// Источник автора изменений задач на основе текущей авторизованной сессии.
final class AuthTaskChangeAuthorProvider implements ITaskChangeAuthorProvider {
  /// Создаёт источник.
  const AuthTaskChangeAuthorProvider({required IAuthGateway authGateway})
    : _authGateway = authGateway;

  final IAuthGateway _authGateway;

  @override
  String? get currentAuthorName {
    final user = _authGateway.currentUser;
    if (user == null) {
      return null;
    }

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    final uid = user.uid.trim();
    if (uid.isNotEmpty) {
      return uid;
    }

    return null;
  }
}
