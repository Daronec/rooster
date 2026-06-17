import 'package:rooster/core/sync/i_sync_manager.dart';

/// Отложенная привязка [ISyncManager] (цикл репозиторий ↔ исполнитель ↔ менеджер).
final class SyncManagerRef {
  /// Активный менеджер; выставляется после сборки графа зависимостей.
  ISyncManager? target;

  /// Запланировать прогон очереди.
  Future<void> scheduleSync() async => target?.requestSync();
}
