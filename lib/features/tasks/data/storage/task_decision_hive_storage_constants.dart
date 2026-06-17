/// Имена Hive-бокса и ключей для локального бюджета и склада.
///
/// Один бокс — меньше открытых дескрипторов; ключи разделяют домены (D2-02).
final class TaskDecisionHiveStorageConstants {
  /// Создаёт константы (не инстанциируется снаружи).
  const TaskDecisionHiveStorageConstants._();

  /// Имя бокса: бюджет + материалы.
  static const String boxName = 'task_decision_v1';

  /// Значение [BudgetPeriodEntity] как map (один активный период).
  static const String budgetActiveKey = 'budget_active';

  /// Список map-записей [MaterialStockItemEntity].
  static const String materialStockItemsKey = 'material_stock_items';

  /// Метаданные синхронизации склада ([MaterialStockSnapshotEntity] без items).
  static const String materialStockSyncMetaKey = 'material_stock_sync_meta';
}
