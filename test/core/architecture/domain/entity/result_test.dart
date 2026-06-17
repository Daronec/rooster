import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/failures/api_failure.dart';

void main() {
  const failure = ApiFailure(
    original: FormatException(),
    trace: StackTrace.empty,
  );

  group('Result.map', () {
    test('ok — ветка success', () {
      const r = Result<int, ApiFailure>.ok(4);
      expect(r.map((x) => x * 2, failed: (_) => -1), 8);
    });

    test('failed — ветка failed', () {
      const r = Result<int, ApiFailure>.failed(failure);
      expect(r.map((x) => x, failed: (_) => 0), 0);
    });
  });

  group('Result.mapResult', () {
    test('ok — маппинг данных', () {
      const r = Result<int, ApiFailure>.ok(3);
      final mapped = r.mapResult((x) => 'v$x');
      expect(mapped.map((s) => s, failed: (_) => ''), 'v3');
    });

    test('failed — пробрасывает тот же failure', () {
      const r = Result<int, ApiFailure>.failed(failure);
      final mapped = r.mapResult((x) => '$x');
      expect(
        mapped.map((_) => false, failed: (f) => identical(f, failure)),
        true,
      );
    });
  });

  group('Result.when', () {
    test('ok — вызывается success', () {
      var seen = 0;
      const Result<int, ApiFailure>.ok(7).when((d) => seen = d);
      expect(seen, 7);
    });

    test('failed — вызывается error', () {
      Object? seen;
      const Result<int, ApiFailure>.failed(
        failure,
      ).when((_) {}, error: (e) => seen = e);
      expect(seen, failure);
    });
  });
}
