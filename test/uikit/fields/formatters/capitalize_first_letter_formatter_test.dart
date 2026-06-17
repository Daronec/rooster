import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/formatters/capitalize_first_letter_formatter.dart';

void main() {
  group('CapitalizeFirstLetterFormatter', () {
    const formatter = CapitalizeFirstLetterFormatter();

    test('пустой ввод без изменений', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue.empty;
      expect(formatter.formatEditUpdate(oldValue, newValue), newValue);
    });

    test('первая буква слова — заглавная', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'hello');
      final out = formatter.formatEditUpdate(oldValue, newValue);
      expect(out.text, 'Hello');
    });
  });
}
