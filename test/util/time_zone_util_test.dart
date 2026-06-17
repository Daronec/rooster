import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/time_zone_util.dart';

void main() {
  group('TimeZoneUtil nullable', () {
    test('parseNullableBackendTime возвращает null для null', () {
      expect(TimeZoneUtil.parseNullableBackendTime(null), isNull);
    });

    test('toNullableBackendTime возвращает null для null', () {
      expect(TimeZoneUtil.toNullableBackendTime(null), isNull);
    });
  });
}
