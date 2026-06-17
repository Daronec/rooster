import 'package:rooster/core/sync/sync_status.dart';

/// Оркестратор: сеть, backoff, drain очереди.
abstract interface class ISyncManager {
  /// Текущий статус.
  SyncEngineStatus get status;

  /// Подписка на смену статуса.
  void addListener(void Function() listener);

  /// Отписка от уведомлений статуса.
  void removeListener(void Function() listener);

  /// Принудительно запустить цикл синхронизации (например после сохранения локально).
  Future<void> requestSync();

  /// Пауза исходящей синхронизации (dev / airplane).
  void setPaused(bool paused);

  /// Освобождение таймеров и подписок.
  void dispose();
}
