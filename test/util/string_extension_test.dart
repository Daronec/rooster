import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/extensions/string_extension.dart';

void main() {
  group('StringExtension.capitalize', () {
    test('пустая строка остаётся пустой', () {
      expect(''.capitalize(), '');
    });

    test('один символ — в верхний регистр', () {
      expect('a'.capitalize(), 'A');
      expect('Z'.capitalize(), 'Z');
    });

    test('первая буква заглавная, остальные без изменений', () {
      expect('hello'.capitalize(), 'Hello');
      expect('Hello'.capitalize(), 'Hello');
    });
  });
}
