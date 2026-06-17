import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/gen/resources/resources.dart';

void main() {
  test('assets_images assets test', () {
    expect(File(AssetsImages.appBar).existsSync(), isTrue);
    expect(File(AssetsImages.authPlace).existsSync(), isTrue);
    expect(File(AssetsImages.desktopAuthPlace).existsSync(), isTrue);
    expect(File(AssetsImages.logo).existsSync(), isTrue);
  });
}
