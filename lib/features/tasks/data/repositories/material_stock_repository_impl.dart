import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/tasks/data/mappers/material_stock_item_codec.dart';
import 'package:rooster/features/tasks/data/storage/task_decision_hive_storage_constants.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/services/material_stock_remote_merge_policy.dart';
import 'package:uuid/uuid.dart';

/// [IMaterialStockRepository] на Hive + синхронизация снимка с облаком.
final class MaterialStockRepositoryImpl implements IMaterialStockRepository {
  /// [decisionBox] — открытый бокс решений (бюджет + материалы).
  MaterialStockRepositoryImpl({
    required Box<dynamic> decisionBox,
    required ISyncQueue syncQueue,
    required SyncManagerRef syncManagerRef,
    required Uuid uuid,
  })  : _box = decisionBox,
        _syncQueue = syncQueue,
        _syncManagerRef = syncManagerRef,
        _uuid = uuid;

  final Box<dynamic> _box;
  final ISyncQueue _syncQueue;
  final SyncManagerRef _syncManagerRef;
  final Uuid _uuid;

  /// Для облачного [ISyncRemoteExecutor].
  Future<MaterialStockSnapshotEntity?> loadStockSnapshot() async {
    final items = await readAllItems();
    final meta = _readSyncMetaMap();
    if (items.isEmpty && meta == null) {
      return null;
    }
    return MaterialStockSnapshotEntity(
      items: items,
      contentRevision: (meta?['contentRevision'] as num?)?.toInt() ?? 0,
      updatedAtMillis: (meta?['updatedAtMillis'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<List<MaterialStockItemEntity>> readAllItems() async {
    final raw = _box.get(TaskDecisionHiveStorageConstants.materialStockItemsKey);
    if (raw is! List) {
      return const [];
    }
    final out = <MaterialStockItemEntity>[];
    for (final entry in raw) {
      if (entry is Map) {
        final item = MaterialStockItemCodec.fromMap(
          Map<String, dynamic>.from(entry),
        );
        if (item.id.isNotEmpty) {
          out.add(item);
        }
      }
    }
    return List<MaterialStockItemEntity>.unmodifiable(out);
  }

  @override
  Future<void> saveAllItems(List<MaterialStockItemEntity> items) async {
    final encoded =
        items.map(MaterialStockItemCodec.toMap).toList(growable: false);
    await _box.put(
      TaskDecisionHiveStorageConstants.materialStockItemsKey,
      encoded,
    );
    final meta = _readSyncMetaMap();
    final nextRevision =
        ((meta?['contentRevision'] as num?)?.toInt() ?? 0) + 1;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _box.put(
      TaskDecisionHiveStorageConstants.materialStockSyncMetaKey,
      <String, Object?>{
        'contentRevision': nextRevision,
        'updatedAtMillis': now,
      },
    );
    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.upsertMaterialStock,
      payload: const {},
      createdAtMillis: now,
    );
    await _syncQueue.enqueue(op);
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<void> mergeRemoteStockIfNewer(
    MaterialStockSnapshotEntity remote,
  ) async {
    final local = await loadStockSnapshot();
    if (!MaterialStockRemoteMergePolicy.remoteStockWins(
      local: local,
      remote: remote,
    )) {
      return;
    }
    final encoded = remote.items
        .map(MaterialStockItemCodec.toMap)
        .toList(growable: false);
    await _box.put(
      TaskDecisionHiveStorageConstants.materialStockItemsKey,
      encoded,
    );
    await _box.put(
      TaskDecisionHiveStorageConstants.materialStockSyncMetaKey,
      <String, Object?>{
        'contentRevision': remote.contentRevision,
        'updatedAtMillis': remote.updatedAtMillis,
      },
    );
  }

  Map<String, dynamic>? _readSyncMetaMap() {
    final raw = _box.get(TaskDecisionHiveStorageConstants.materialStockSyncMetaKey);
    if (raw is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(raw);
  }
}
