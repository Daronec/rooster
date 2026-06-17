import 'package:rooster/uikit/fields/validators/field_validator.dart';

/// Validator that checks if the field is filled.
class LinkValidator extends FieldValidator<String> {
  /// Creates an instance of [LinkValidator].
  const LinkValidator();

  @override
  String? validate(String? value) {
    final linkRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)',
    );

    if (value == null || value.trim().isEmpty) {
      return 'RequiredFieldError';
    }

    if (!linkRegex.hasMatch(value)) {
      return 'InvalidLinkError';
    }

    return null;
  }
}
