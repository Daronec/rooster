import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/features/tasks/data/mappers/budget_period_codec.dart';
import 'package:rooster/features/tasks/data/storage/task_decision_hive_storage_constants.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';

/// [IBudgetRepository] на одном ключе Hive внутри [TaskDecisionHiveStorageConstants.boxName].
final class BudgetRepositoryImpl implements IBudgetRepository {
  /// [decisionBox] — открытый бокс решений (бюджет + материалы).
  BudgetRepositoryImpl({required Box<dynamic> decisionBox})
      : _box = decisionBox;

  final Box<dynamic> _box;

  @override
  Future<BudgetPeriodEntity?> readActivePeriod() async {
    final raw = _box.get(TaskDecisionHiveStorageConstants.budgetActiveKey);
    if (raw == null) {
      return null;
    }
    if (raw is! Map) {
      return null;
    }
    return BudgetPeriodCodec.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Stream<BudgetPeriodEntity?> watchActivePeriod() async* {
    yield await readActivePeriod();
    await for (final _ in _box.watch(key: TaskDecisionHiveStorageConstants.budgetActiveKey)) {
      yield await readActivePeriod();
    }
  }

  @override
  Future<void> saveActivePeriod(BudgetPeriodEntity period) async {
    await _box.put(
      TaskDecisionHiveStorageConstants.budgetActiveKey,
      BudgetPeriodCodec.toMap(period),
    );
  }

  @override
  Future<void> clearActivePeriod() async {
    await _box.delete(TaskDecisionHiveStorageConstants.budgetActiveKey);
  }
}
