import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('корректный email — null', () {
      final v = EmailValidator<Object>();
      expect(v.validate('user@example.com'), isNull);
      expect(v.validate('a.b@sub.domain.org'), isNull);
    });

    test('некорректная строка — ключ ошибки', () {
      final v = EmailValidator<Object>();
      expect(v.validate('not-an-email'), 'InvalidFieldMaxLengthError');
      expect(v.validate('missing@'), 'InvalidFieldMaxLengthError');
    });

    test('null — ошибка', () {
      final v = EmailValidator<Object>();
      expect(v.validate(null), 'InvalidFieldMaxLengthError');
    });

    group('skipForEmptyValue', () {
      test('пустая строка — null', () {
        final v = EmailValidator<Object>(skipForEmptyValue: true);
        expect(v.validate(''), isNull);
        expect(v.validate('   '), isNull);
      });

      test('непустая невалидная — ошибка', () {
        final v = EmailValidator<Object>(skipForEmptyValue: true);
        expect(v.validate('bad'), 'InvalidFieldMaxLengthError');
      });
    });
  });
}
