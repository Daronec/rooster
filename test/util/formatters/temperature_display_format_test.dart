import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/formatters/temperature_display_format.dart';

void main() {
  group('formatCelsiusForDisplay', () {
    test('null — плейсхолдер без данных', () {
      expect(formatCelsiusForDisplay(null), kTemperatureDisplayNoData);
    });

    test('положительная температура — знак + и один знак после запятой', () {
      expect(formatCelsiusForDisplay(21.3), '+21.3°C');
    });

    test('ноль — без плюса', () {
      expect(formatCelsiusForDisplay(0), '0.0°C');
    });

    test('отрицательная — минус из числа', () {
      expect(formatCelsiusForDisplay(-3.5), '-3.5°C');
    });
  });
}
