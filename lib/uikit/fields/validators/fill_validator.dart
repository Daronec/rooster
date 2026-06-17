import 'package:rooster/uikit/fields/validators/field_validator.dart';

/// Validator that checks if the field is filled.
class FillValidator<T extends Object?> extends FieldValidator<T> {
  /// Creates an instance of [FillValidator].
  const FillValidator();

  @override
  String? validate(Object? value) {
    if (value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is Iterable && value.isEmpty)) {
      return 'RequiredFieldError';
    }

    return null;
  }
}
