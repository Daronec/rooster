import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/fill_validator.dart';
import 'package:rooster/uikit/fields/validators/max_length_validator.dart';
import 'package:rooster/uikit/fields/validators/merged_validator.dart';

void main() {
  group('MergedValidator', () {
    const v = MergedValidator<Object>([
      FillValidator(),
      MaxLengthValidator<Object>(maxLength: 2),
    ]);

    test('возвращает первую ошибку — Fill', () {
      expect(v.validate(null), 'RequiredFieldError');
      expect(v.validate(''), 'RequiredFieldError');
    });

    test('после Fill — MaxLength', () {
      expect(v.validate('abc'), 'InvalidFieldMaxLengthError');
    });

    test('все проходят — null', () {
      expect(v.validate('ab'), isNull);
    });
  });
}
