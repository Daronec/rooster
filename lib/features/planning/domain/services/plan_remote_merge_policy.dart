import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';

/// Правило «кто новее» при входящей синхронизации планов с Appwrite.
abstract final class PlanRemoteMergePolicy {
  /// Возвращает `true`, если удалённый план должен заменить локальную запись.
  static bool remotePlanWins({
    required PlanningPlanEntity? local,
    required PlanningPlanEntity remote,
  }) {
    if (local == null) {
      return true;
    }
    if (remote.updatedAtMillis > local.updatedAtMillis) {
      return true;
    }
    if (remote.updatedAtMillis < local.updatedAtMillis) {
      return false;
    }
    return remote.contentRevision >= local.contentRevision;
  }
}
