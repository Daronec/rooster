import 'package:elementary/elementary.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';

/// Входные данные для выбора стартового маршрута по сессии.
final class RootAuthGateModel extends ElementaryModel {
  /// Создаёт модель.
  RootAuthGateModel({
    required IAuthGateway authGateway,
    required this.authBackendStrategy,
  }) : _authGateway = authGateway;

  final IAuthGateway _authGateway;

  /// Шлюз авторизации.
  IAuthGateway get authGateway => _authGateway;

  /// Стратегия бэкенда; при [AuthBackendStrategy.offlineOnly] вход в облако не предлагается.
  final AuthBackendStrategy authBackendStrategy;
}
