import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/gen/resources/resources.dart';

void main() {
  test('assets_icons assets test', () {
    expect(File(AssetsIcons.check).existsSync(), isTrue);
    expect(File(AssetsIcons.down).existsSync(), isTrue);
    expect(File(AssetsIcons.layers).existsSync(), isTrue);
    expect(File(AssetsIcons.lightbulb).existsSync(), isTrue);
    expect(File(AssetsIcons.list).existsSync(), isTrue);
    expect(File(AssetsIcons.shield).existsSync(), isTrue);
  });
}
