import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Абстракция доступности сети для sync engine.
abstract interface class IConnectivityGateway {
  /// Подписка на изменения (wifi/mobile/none).
  Stream<bool> get onOnline;

  /// Текущее предположение о наличии сети.
  Future<bool> isOnline();
}

/// Реализация на [ConnectivityPlus].
final class ConnectivityGateway implements IConnectivityGateway {
  /// Создаёт шлюз.
  ConnectivityGateway({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<bool> get onOnline {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  @override
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }
}
