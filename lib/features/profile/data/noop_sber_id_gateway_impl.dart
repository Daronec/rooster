import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';
import 'package:rxdart/rxdart.dart';

/// Noop-реализация [ISberIdGateway] и [IAuthGateway].
///
/// Используется в тестовой среде или когда авторизация не требуется.
final class NoopSberIdGatewayImpl implements ISberIdGateway, IAuthGateway {
  /// Создаёт noop-реализацию.
  NoopSberIdGatewayImpl();

  final BehaviorSubject<AppAuthUserEntity?> _subject =
      BehaviorSubject<AppAuthUserEntity?>.seeded(null);

  @override
  bool get isSberIdAvailable => false;

  @override
  Future<void> signInWithSberId() async {}

  @override
  Stream<AppAuthUserEntity?> get authStateChanges => _subject.stream;

  @override
  AppAuthUserEntity? get currentUser => null;

  @override
  Future<void> signOut() async {}

  @override
  void dispose() {
    _subject.close();
  }
}
