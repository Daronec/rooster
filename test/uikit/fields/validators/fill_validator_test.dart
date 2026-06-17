import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/fill_validator.dart';

void main() {
  group('FillValidator', () {
    const v = FillValidator<Object>();

    test('null — RequiredFieldError', () {
      expect(v.validate(null), 'RequiredFieldError');
    });

    test('пустая или пробельная строка — RequiredFieldError', () {
      expect(v.validate(''), 'RequiredFieldError');
      expect(v.validate('   '), 'RequiredFieldError');
    });

    test('пустой Iterable — RequiredFieldError', () {
      expect(v.validate(<String>[]), 'RequiredFieldError');
    });

    test('непустая строка — null', () {
      expect(v.validate('x'), isNull);
    });

    test('непустой список — null', () {
      expect(v.validate(['a']), isNull);
    });
  });
}
