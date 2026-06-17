/// Бюджетный период (например месяц) для проверки денег на задачи.
final class BudgetPeriodEntity {
  /// Создаёт период.
  const BudgetPeriodEntity({
    required this.year,
    required this.month,
    required this.amountLimit,
    this.amountSpent = 0,
  });

  /// Календарный год.
  final int year;

  /// Месяц 1–12.
  final int month;

  /// Лимит средств за период (в валюте UI).
  final double amountLimit;

  /// Уже учтённые траты за период (MVP: может обновляться вручную или из задач).
  final double amountSpent;

  /// Остаток до лимита; не ниже нуля.
  double get remaining => (amountLimit - amountSpent).clamp(0.0, double.infinity);
}
