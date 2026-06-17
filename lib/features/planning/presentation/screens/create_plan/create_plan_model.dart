import 'package:elementary/elementary.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';

/// Модель экрана создания плана.
final class CreatePlanModel extends ElementaryModel {
  /// Создаёт модель.
  CreatePlanModel({required IPlanningRepository planningRepository})
    : _planningRepository = planningRepository;

  final IPlanningRepository _planningRepository;

  /// Сохранить план.
  Future<void> savePlan(PlanningPlanEntity plan) =>
      _planningRepository.savePlan(plan);
}
