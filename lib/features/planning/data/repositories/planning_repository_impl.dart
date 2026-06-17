import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/planning/data/mappers/planning_plan_entity_codec.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/planning/domain/services/plan_remote_merge_policy.dart';
import 'package:uuid/uuid.dart';

/// Локальный репозиторий планов + синхронизация с облаком.
final class PlanningRepositoryImpl implements IPlanningRepository {
  /// Создаёт репозиторий.
  PlanningRepositoryImpl({
    required Box<dynamic> planningBox,
    required ISyncQueue syncQueue,
    required SyncManagerRef syncManagerRef,
    required Uuid uuid,
  })  : _box = planningBox,
        _syncQueue = syncQueue,
        _syncManagerRef = syncManagerRef,
        _uuid = uuid;

  final Box<dynamic> _box;
  final ISyncQueue _syncQueue;
  final SyncManagerRef _syncManagerRef;
  final Uuid _uuid;

  /// Для облачного [ISyncRemoteExecutor].
  Future<PlanningPlanEntity?> loadPlanById(String planId) => loadPlan(planId);

  @override
  Future<void> deletePlan(String planId) async {
    await _box.delete(planId);
    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.deletePlan,
      payload: {'planId': planId},
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<PlanningPlanEntity?> loadPlan(String planId) async {
    final raw = _box.get(planId);
    if (raw is! Map) {
      return null;
    }
    return PlanningPlanEntityCodec.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> savePlan(PlanningPlanEntity plan) async {
    final local = await loadPlan(plan.id);
    final nextRevision = (local?.contentRevision ?? 0) + 1;
    final toSave = plan.copyWith(contentRevision: nextRevision);
    await _box.put(plan.id, PlanningPlanEntityCodec.toMap(toSave));
    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.upsertPlan,
      payload: {'planId': plan.id},
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<void> mergeRemotePlanIfNewer(PlanningPlanEntity remote) async {
    final local = await loadPlan(remote.id);
    if (!PlanRemoteMergePolicy.remotePlanWins(local: local, remote: remote)) {
      return;
    }
    await _box.put(remote.id, PlanningPlanEntityCodec.toMap(remote));
  }

  @override
  Stream<List<PlanningPlanEntity>> watchPlans() async* {
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  List<PlanningPlanEntity> _readAll() {
    final plans = <PlanningPlanEntity>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is! Map) {
        continue;
      }
      plans.add(
        PlanningPlanEntityCodec.fromMap(Map<String, dynamic>.from(raw)),
      );
    }
    plans.sort(
      (left, right) => right.updatedAtMillis.compareTo(left.updatedAtMillis),
    );
    return List<PlanningPlanEntity>.unmodifiable(plans);
  }
}
