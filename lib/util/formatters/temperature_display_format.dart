/// Плейсхолдер «нет данных» для отображения температуры в UI.
const String kTemperatureDisplayNoData = '—';

/// Форматирует температуру в °C для подписи на экране: знак `+` для положительных,
/// один знак после запятой, суффикс `°C`. При [celsius] == `null` — [kTemperatureDisplayNoData].
String formatCelsiusForDisplay(double? celsius) {
  if (celsius == null) return kTemperatureDisplayNoData;
  final sign = celsius > 0 ? '+' : '';
  return '$sign${celsius.toStringAsFixed(1)}°C';
}
