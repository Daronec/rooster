
import 'package:rooster/uikit/fields/validators/fill_validator.dart';
import 'package:rooster/uikit/fields/validators/merged_validator.dart';

/// Abstract class for field validator.
///
/// This class is used to validate the value of the field.
///
/// The `call` method should return `null` if the value is valid.
abstract class FieldValidator<T extends Object?> {
  /// Creates an instance of [FieldValidator].
  const FieldValidator();

  /// Validates the value.
  ///
  /// Returns `null` if the value is valid.
  ///
  /// Otherwise, returns an error message.
  String? validate(T? value);

  /// Combines this validator with another one.
  FieldValidator<T> required() => MergedValidator([const FillValidator(), this]);
}
