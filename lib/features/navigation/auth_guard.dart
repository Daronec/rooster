import 'package:auto_route/auto_route.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/persistence/storage/tokens_storage/token_storage_impl.dart';

/// Guard: защищённые маршруты только при наличии токена; иначе редирект в [AuthFlowRoute].
class AuthGuard extends AutoRouteGuard {
  /// Создаёт гвард с хранилищем токенов.
  AuthGuard({required ITokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  final ITokenStorage _tokenStorage;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (resolver.routeName != AuthFlowRoute.name) {
      _checkProtectedRoute(resolver);
      return;
    }
    resolver.next();
  }

  void _checkProtectedRoute(NavigationResolver resolver) {
    _tokenStorage.read().then((token) {
      if (token != null) {
        resolver.next();
      } else {
        resolver.redirectUntil(const AuthFlowRoute());
      }
    }).catchError((_, __) {
      resolver.redirectUntil(const AuthFlowRoute());
    });
  }
}
