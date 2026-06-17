import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';

/// Репозиторий планов.
abstract interface class IPlanningRepository {
  /// Поток всех планов.
  Stream<List<PlanningPlanEntity>> watchPlans();

  /// Загрузить план по [planId].
  Future<PlanningPlanEntity?> loadPlan(String planId);

  /// Сохранить план.
  Future<void> savePlan(PlanningPlanEntity plan);

  /// Удалить план.
  Future<void> deletePlan(String planId);

  /// Входящая синхронизация: заменить локальный план, если снимок с облака новее.
  Future<void> mergeRemotePlanIfNewer(PlanningPlanEntity remote);
}
