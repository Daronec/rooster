import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/api/data/info_errors_dto.dart';
import 'package:rooster/core/failures/api_failure.dart';

void main() {
  group('ApiFailure getters', () {
    test('isPhoneNumberNotFound при statusCode 4001', () {
      const f = ApiFailure(
        original: FormatException(),
        trace: StackTrace.empty,
        statusCode: 4001,
      );
      expect(f.isPhoneNumberNotFound, isTrue);
      expect(f.isOtpExpired, isFalse);
    });

    test('isOtpExpired при 4002, isOtpIncorrect при 4003', () {
      const expired = ApiFailure(
        original: FormatException(),
        trace: StackTrace.empty,
        statusCode: 4002,
      );
      const incorrect = ApiFailure(
        original: FormatException(),
        trace: StackTrace.empty,
        statusCode: 4003,
      );
      expect(expired.isOtpExpired, isTrue);
      expect(incorrect.isOtpIncorrect, isTrue);
    });
  });

  group('ApiFailure.description', () {
    test('при непустом infoErrors — message первого элемента', () {
      const f = ApiFailure(
        original: FormatException(),
        trace: StackTrace.empty,
        message: 'fallback',
        infoErrors: [InfoErrorsDto(field: 'f', message: 'from dto')],
      );
      expect(f.description, 'from dto');
    });

    test('при пустом infoErrors — поле message', () {
      const f = ApiFailure(
        original: FormatException(),
        trace: StackTrace.empty,
        message: 'only message',
      );
      expect(f.description, 'only message');
    });
  });
}
