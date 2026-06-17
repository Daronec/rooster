import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_operation.dart';

/// Реализация [ISyncQueue] на Hive (список операций в одном боксе).
final class SyncQueueHiveStorage implements ISyncQueue {
  /// Создаёт хранилище очереди.
  SyncQueueHiveStorage(this._box);

  final Box<dynamic> _box;

  static const _listKey = 'operations';

  final StreamController<void> _changeController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changeController.stream;

  List<Map<String, dynamic>> _readRawList() {
    final raw = _box.get(_listKey);
    if (raw is! List) {
      return [];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<void> _writeRawList(List<Map<String, dynamic>> list) async {
    await _box.put(_listKey, list);
    _changeController.add(null);
  }

  @override
  Future<List<SyncOperation>> loadAll() async {
    return _readRawList().map(SyncOperation.fromMap).toList();
  }

  @override
  Future<void> enqueue(SyncOperation operation) async {
    final list = _readRawList();
    list.add(operation.toMap().cast<String, dynamic>());
    await _writeRawList(list);
  }

  @override
  Future<void> remove(String operationId) async {
    final list =
        _readRawList().where((m) => m['id'] != operationId).toList();
    await _writeRawList(list);
  }

  @override
  Future<void> update(SyncOperation operation) async {
    final list = _readRawList();
    final index = list.indexWhere((m) => m['id'] == operation.id);
    if (index < 0) {
      return;
    }
    list[index] = operation.toMap().cast<String, dynamic>();
    await _writeRawList(list);
  }

  /// Закрытие контроллера (при dispose scope).
  void dispose() {
    _changeController.close();
  }
}
