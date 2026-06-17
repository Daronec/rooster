import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';

/// Сериализация [BudgetPeriodEntity] ↔ Hive map.
final class BudgetPeriodCodec {
  const BudgetPeriodCodec._();

  /// Версия записи в боксе (для будущих миграций).
  static const int currentSchemaVersion = 1;

  /// Карта для Hive.
  static Map<String, Object?> toMap(BudgetPeriodEntity entity) {
    return {
      'schemaVersion': currentSchemaVersion,
      'year': entity.year,
      'month': entity.month,
      'amountLimit': entity.amountLimit,
      'amountSpent': entity.amountSpent,
    };
  }

  /// Восстановление из Hive.
  static BudgetPeriodEntity fromMap(Map<String, dynamic> map) {
    return BudgetPeriodEntity(
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (map['month'] as num?)?.toInt().clamp(1, 12) ?? 1,
      amountLimit: _readDouble(map['amountLimit']),
      amountSpent: _readDouble(map['amountSpent']),
    );
  }

  static double _readDouble(Object? raw) {
    final value = (raw as num?)?.toDouble();
    if (value == null || value.isNaN) {
      return 0;
    }
    return value < 0 ? 0 : value;
  }
}
