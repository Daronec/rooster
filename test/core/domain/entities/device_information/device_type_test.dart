import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/core/domain/entities/device_information/device_type.dart';

void main() {
  test('DeviceType.key и formatted', () {
    expect(DeviceType.android.key, 'android');
    expect(DeviceType.android.formatted, 'Android');
    expect(DeviceType.ios.key, 'ios');
    expect(DeviceType.ios.formatted, 'iOS');
  });
}
