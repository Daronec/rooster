import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/core/domain/entities/device_information/client_type.dart';

void main() {
  test('ClientType.key соответствует значению enum', () {
    expect(ClientType.web.key, 'web');
    expect(ClientType.app.key, 'app');
  });

  test('values содержит все варианты', () {
    expect(ClientType.values.length, 2);
  });
}
