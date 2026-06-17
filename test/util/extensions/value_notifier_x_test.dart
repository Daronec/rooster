import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/extensions/value_notifier_x.dart';
import 'package:union_state/union_state.dart';

void main() {
  group('PageStateNotifier', () {
    test('content — UnionStateContent', () {
      final n = PageStateNotifier();
      n.content();
      expect(n.value.isContent, isTrue);
      expect(n.value.isLoading, isFalse);
      expect(n.value.isFailure, isFalse);
    });

    test('loading — UnionStateLoading', () {
      final n = PageStateNotifier();
      n.loading();
      expect(n.value.isLoading, isTrue);
    });

    test('failure — UnionStateFailure и exceptionOrNull', () {
      final n = PageStateNotifier();
      final ex = Exception('e');
      n.failure(exception: ex);
      expect(n.value.isFailure, isTrue);
      expect(n.value.exceptionOrNull, ex);
    });
  });

  group('UnionStateX', () {
    test('exceptionOrNull для content — null', () {
      const state = UnionStateContent<void>(null);
      expect(state.exceptionOrNull, isNull);
    });
  });
}
