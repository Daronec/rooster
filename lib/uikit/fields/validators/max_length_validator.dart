import 'package:rooster/uikit/fields/validators/field_validator.dart';

/// {@template max_length_validator.class}
/// Validator that checks max allowed length of a string.
/// {@endtemplate}
class MaxLengthValidator<T extends Object> extends FieldValidator<T> {

  /// Creates an instance of [MaxLengthValidator].
  const MaxLengthValidator({required this.maxLength});
  /// Max allowed length.
  final int maxLength;

  @override
  String? validate(Object? value) {
    if (value != null && value is String && value.trim().length > maxLength) {
      return 'InvalidFieldMaxLengthError';
    }

    return null;
  }
}
