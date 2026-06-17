import 'package:rooster/uikit/fields/validators/field_validator.dart';

/// Validator that checks if the person's name related fields (name, surname, etc) are valid.
class NameValidator<T extends Object> extends FieldValidator<T> {

  /// Creates an instance of [NameValidator].
  NameValidator({this.skipForEmptyValue = false}) {
    _regExp = RegExp(_personNameAllowedSymbols);
  }
  /// Validate only if value is presented.
  final bool skipForEmptyValue;

  /// Allowed symbols for person's name related fields.
  final _personNameAllowedSymbols = r'^[a-zA-ZА-яЁё]+(?:[-\s][a-zA-ZА-яЁё]+)*$';

  /// Regexp to check allowed symbols.
  late final RegExp _regExp;

  @override
  String? validate(Object? value) {
    if (skipForEmptyValue &&
        (value == null || (value is String && value.trim().isEmpty))) {
      return null;
    }

    if (value == null || (value is String && !_regExp.hasMatch(value))) {
      return 'InvalidFieldValueError';
    }

    return null;
  }
}
