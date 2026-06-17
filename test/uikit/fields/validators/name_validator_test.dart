import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/name_validator.dart';

void main() {
  group('NameValidator', () {
    test('корректные имена — null', () {
      final v = NameValidator<Object>();
      expect(v.validate('Иван'), isNull);
      expect(v.validate('John'), isNull);
      expect(v.validate('Mary-Jane'), isNull);
      expect(v.validate('Иван Петров'), isNull);
    });

    test('некорректные значения — InvalidFieldValueError', () {
      final v = NameValidator<Object>();
      expect(v.validate(null), 'InvalidFieldValueError');
      expect(v.validate('123'), 'InvalidFieldValueError');
      expect(v.validate('Иван123'), 'InvalidFieldValueError');
    });

    group('skipForEmptyValue', () {
      test('пусто — null', () {
        final v = NameValidator<Object>(skipForEmptyValue: true);
        expect(v.validate(null), isNull);
        expect(v.validate(''), isNull);
        expect(v.validate('  '), isNull);
      });
    });
  });
}
