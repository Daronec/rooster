import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rooster/common/utils/disposable_object/i_disposable_object.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/app_config.dart';
import 'package:rooster/config/environment/environment.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';
import 'package:rooster/persistence/storage/pin_code_storage/i_pin_code_storage.dart';
import 'package:rooster/persistence/storage/tokens_storage/token_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template core_scope.class}
/// Корневой scope приложения — только инфраструктурные зависимости.
/// {@endtemplate}
///
/// Выделен для соблюдения Interface Segregation Principle (ISP):
/// клиенты, которым нужна только инфраструктура (логгер, хранение,
/// синхронизация), зависят от [ICoreScope], а не от всего [IAppScope].
abstract interface class ICoreScope implements IDisposableObject {
  /// Окружение.
  Environment get env;

  /// Конфиг приложения.
  AppConfig get appConfig;

  /// SharedPreferences.
  SharedPreferences get sharedPreferences;

  /// Логгер.
  ILogWriter get logger;

  /// Локальные уведомления (плагин).
  FlutterLocalNotificationsPlugin get localNotificationsPlugin;

  /// Токены (secure).
  ITokenStorage get tokenStorage;

  /// PIN-хранилище (наследие инфраструктуры; можно отключить в UI).
  IPinCodeStorage get pinCodeStorage;

  /// Очередь синхронизации (dev / диагностика).
  ISyncQueue get syncQueue;

  /// Менеджер синхронизации.
  ISyncManager get syncManager;

  /// [Listenable] статуса синка ([ChangeNotifier] реализации менеджера).
  Listenable get syncEngineListenable;

  /// Сеть.
  IConnectivityGateway get connectivityGateway;
}
