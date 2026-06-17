/// Битовая маска дней недели для постоянного напоминания (Пн = 1, Вт = 2, … Вс = 64).
abstract final class TaskWeekdayMaskEntity {
  /// Понедельник.
  static const int monday = 1 << 0;

  /// Вторник.
  static const int tuesday = 1 << 1;

  /// Среда.
  static const int wednesday = 1 << 2;

  /// Четверг.
  static const int thursday = 1 << 3;

  /// Пятница.
  static const int friday = 1 << 4;

  /// Суббота.
  static const int saturday = 1 << 5;

  /// Воскресенье.
  static const int sunday = 1 << 6;

  /// Все дни выключены.
  static const int empty = 0;

  /// Проверка, включён ли день в маске.
  static bool hasDay(int mask, int dayBit) => mask & dayBit != 0;

  /// Переключить день в маске.
  static int toggle(int mask, int dayBit) => mask ^ dayBit;
}
