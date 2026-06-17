import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/fields/validators/link_validator.dart';

void main() {
  group('LinkValidator', () {
    const v = LinkValidator();

    test('корректный http(s) URL — null', () {
      expect(v.validate('https://example.com'), isNull);
      expect(v.validate('http://sub.domain.co/path?q=1'), isNull);
    });

    test('null или пусто — RequiredFieldError', () {
      expect(v.validate(null), 'RequiredFieldError');
      expect(v.validate(''), 'RequiredFieldError');
      expect(v.validate('   '), 'RequiredFieldError');
    });

    test('похоже на текст, не URL — InvalidLinkError', () {
      expect(v.validate('not a link'), 'InvalidLinkError');
      expect(v.validate('ftp://example.com'), 'InvalidLinkError');
    });
  });
}
