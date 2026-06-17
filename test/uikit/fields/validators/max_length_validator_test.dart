import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/max_length_validator.dart';

void main() {
  group('MaxLengthValidator', () {
    const v = MaxLengthValidator<Object>(maxLength: 3);

    test('длина не больше max — null', () {
      expect(v.validate(''), isNull);
      expect(v.validate('ab'), isNull);
      expect(v.validate('abc'), isNull);
    });

    test('после trim длина больше max — ошибка', () {
      expect(v.validate('  abcd  '), 'InvalidFieldMaxLengthError');
      expect(v.validate('abcd'), 'InvalidFieldMaxLengthError');
    });

    test('не строка — null', () {
      expect(v.validate(42), isNull);
    });
  });
}
