import 'package:rooster/uikit/fields/validators/field_validator.dart';

/// Validator that combines multiple validators.
///
/// This validator returns the first error message from the list of validators.
class MergedValidator<T extends Object?> extends FieldValidator<T> {

  /// Creates an instance of [MergedValidator].
  const MergedValidator(this.validators);
  /// List of validators.
  final List<FieldValidator<T>> validators;

  @override
  String? validate(T? value) {
    for (final validator in validators) {
      final result = validator.validate(value);
      if (result != null) {
        return result;
      }
    }

    return null;
  }
}
