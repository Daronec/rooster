/// Персистентность набора развёрнутых групп (списков) на экране задач.
abstract interface class ITasksScreenExpandedGroupStorage {
  /// Сохранённые id развёрнутых списков; пустой набор — все свёрнуты.
  Future<Set<String>> loadExpandedListIds();

  /// Сохранить набор развёрнутых списков.
  Future<void> saveExpandedListIds(Set<String> listIds);
}
