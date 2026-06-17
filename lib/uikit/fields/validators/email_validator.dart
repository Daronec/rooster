import 'package:rooster/uikit/fields/validators/field_validator.dart';

/// {@template email_validator.class}
/// Validator that checks email string is valid.
/// {@endtemplate}
class EmailValidator<T extends Object> extends FieldValidator<T> {

  /// Creates an instance of [EmailValidator].
  EmailValidator({this.skipForEmptyValue = false}) {
    _regExp = RegExp(_emailPattern);
  }
  /// Validate only if value is presented.
  final bool skipForEmptyValue;

  /// Email pattern.
  final _emailPattern = r'^[\w\-\.]+@([\w-]+\.)+[\w-]+$';

  /// Regexp to check allowed symbols.
  late final RegExp _regExp;

  @override
  String? validate(Object? value) {
    if (skipForEmptyValue &&
        (value == null || (value is String && value.trim().isEmpty))) {
      return null;
    }

    if (value == null || (value is String && !_regExp.hasMatch(value))) {
      return 'InvalidFieldMaxLengthError';
    }

    return null;
  }
}
