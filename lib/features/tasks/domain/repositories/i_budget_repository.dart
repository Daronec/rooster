import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';

/// Бюджетный период для проверки денег на задачи (ISP: отдельно от [ITasksRepository]).
///
/// MVP: только локальный Hive, без sync queue (см. DECISION_SYSTEM_IMPLEMENTATION.md).
abstract interface class IBudgetRepository {
  /// Активный период для текущей логики приложения; null — лимит не задан.
  Future<BudgetPeriodEntity?> readActivePeriod();

  /// Изменения активного периода (для реактивного пересчёта решений).
  Stream<BudgetPeriodEntity?> watchActivePeriod();

  /// Сохранить единственный активный период (перезапись).
  Future<void> saveActivePeriod(BudgetPeriodEntity period);

  /// Удалить активный период ([readActivePeriod] начнёт возвращать null).
  Future<void> clearActivePeriod();
}
