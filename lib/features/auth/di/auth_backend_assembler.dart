import 'package:rooster/features/auth/di/auth_backend_assembly_context.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_result.dart';
import 'package:rooster/features/auth/di/i_auth_backend_assembly_strategy.dart';
import 'package:rooster/features/auth/di/strategies/appwrite_auth_backend_assembly_strategy.dart';
import 'package:rooster/features/auth/di/strategies/offline_auth_backend_assembly_strategy.dart';

/// Собирает облачный бэкенд авторизации: Appwrite или только локально.
Future<AuthBackendAssemblyResult> assembleAuthBackend(
  AuthBackendAssemblyContext context,
) async {
  const strategies = <IAuthBackendAssemblyStrategy>[
    AppwriteAuthBackendAssemblyStrategy(),
    OfflineAuthBackendAssemblyStrategy(),
  ];
  for (final strategy in strategies) {
    final result = await strategy.tryAssemble(context);
    if (result != null) {
      return result;
    }
  }
  throw StateError('Auth backend: no assembly strategy matched the context');
}
