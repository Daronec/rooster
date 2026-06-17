import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';

/// Заглушка для сборки без данных бюджета: [readActivePeriod] всегда null (денежная блокировка не применяется).
final class NoopBudgetRepository implements IBudgetRepository {
  /// Создаёт заглушку.
  const NoopBudgetRepository();

  @override
  Future<BudgetPeriodEntity?> readActivePeriod() async => null;

  @override
  Stream<BudgetPeriodEntity?> watchActivePeriod() async* {
    yield null;
  }

  @override
  Future<void> saveActivePeriod(BudgetPeriodEntity period) async {}

  @override
  Future<void> clearActivePeriod() async {}
}
