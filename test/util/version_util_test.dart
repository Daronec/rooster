import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/version_util.dart';

void main() {
  group('VersionUtil.compareVersions', () {
    test('оба null — true', () {
      expect(VersionUtil.compareVersions(null, null), isTrue);
    });

    test('один из аргументов null — true', () {
      expect(VersionUtil.compareVersions(null, '1.0.4'), isTrue);
      expect(VersionUtil.compareVersions('1.0.0', null), isTrue);
    });

    test('пустая строка — true', () {
      expect(VersionUtil.compareVersions('', '1.0.0'), isTrue);
      expect(VersionUtil.compareVersions('1.0.0', ''), isTrue);
    });

    test('одинаковые строки — true', () {
      expect(VersionUtil.compareVersions('1.2.3', '1.2.3'), isTrue);
    });

    test('первая версия больше — true', () {
      expect(VersionUtil.compareVersions('1.1.0', '1.0.3'), isTrue);
      expect(VersionUtil.compareVersions('3', '1.5.3'), isTrue);
    });

    test('первая версия меньше — false', () {
      expect(VersionUtil.compareVersions('1', '2.0.4'), isFalse);
      expect(VersionUtil.compareVersions('1.0.0', '2.0.0'), isFalse);
    });
  });

  group('VersionUtil.isSameVersions', () {
    test('совпадающие сегменты — true', () {
      expect(
        VersionUtil.isSameVersions(first: '1.2.3', second: '1.2.3'),
        isTrue,
      );
    });

    test('различаются — false', () {
      expect(
        VersionUtil.isSameVersions(first: '1.0.0', second: '1.0.1'),
        isFalse,
      );
    });

    test('некорректный формат — false', () {
      expect(
        VersionUtil.isSameVersions(first: 'a.b', second: '1.0.0'),
        isFalse,
      );
    });
  });

  group('VersionUtil.getFormattedVersion', () {
    test('убирает суффикс -dev', () {
      expect(VersionUtil.getFormattedVersion('1.0.0-dev'), '1.0.0');
    });

    test('строка без -dev не меняется', () {
      expect(VersionUtil.getFormattedVersion('2.3.4'), '2.3.4');
    });
  });
}
