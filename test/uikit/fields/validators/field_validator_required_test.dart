import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/email_validator.dart';

void main() {
  group('FieldValidator.required', () {
    final v = EmailValidator<Object>().required();

    test('пустое значение — сначала RequiredFieldError', () {
      expect(v.validate(null), 'RequiredFieldError');
      expect(v.validate(''), 'RequiredFieldError');
    });

    test('непустое, но невалидный email — ошибка email', () {
      expect(v.validate('not-email'), 'InvalidFieldMaxLengthError');
    });

    test('валидный email — null', () {
      expect(v.validate('user@example.com'), isNull);
    });
  });
}
