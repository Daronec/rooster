import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/extensions/closures.dart';

void main() {
  group('LetX.let', () {
    test('передаёт значение в замыкание', () {
      expect(2.let((x) => x * 3), 6);
      expect('ab'.let((s) => s.length), 2);
    });
  });

  group('LetNullableX.let', () {
    test('null — результат null', () {
      const int? n = null;
      expect(n.let((x) => x + 1), isNull);
    });

    test('не null — выполняется замыкание', () {
      const n = 5;
      expect(n.let((x) => x * 2), 10);
    });
  });

  group('AlsoX.also', () {
    test('выполняет побочный эффект и возвращает исходное значение', () {
      var side = 0;
      final v = 7.also((x) {
        side = x;
      });
      expect(v, 7);
      expect(side, 7);
    });
  });
}
