import 'package:rooster/features/auth/di/auth_backend_assembly_context.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_result.dart';

/// Стратегия сборки облачной авторизации и связанных шлюзов (sync, профиль).
///
/// Каждая реализация отвечает за один способ сборки (Appwrite или только локально).
/// Новый провайдер добавляется новым классом и регистрацией в [assembleAuthBackend].
abstract interface class IAuthBackendAssemblyStrategy {
  /// Собрать бэкенд или вернуть `null`, если контекст к этой стратегии не подходит.
  Future<AuthBackendAssemblyResult?> tryAssemble(AuthBackendAssemblyContext context);
}
