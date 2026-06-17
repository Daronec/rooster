import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/core/domain/entities/app_information/version_and_build_number_couple.dart';

void main() {
  test('VersionAndBuildNumberCouple хранит версию и номер сборки', () {
    const c = VersionAndBuildNumberCouple(version: '1.2.3', buildNumber: '42');
    expect(c.version, '1.2.3');
    expect(c.buildNumber, '42');
  });
}
