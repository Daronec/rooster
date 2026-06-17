import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/core/domain/entities/auth_tokens.dart';

void main() {
  group('AuthTokens', () {
    const a = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

    test('одинаковые поля — равенство', () {
      const b = AuthTokens(accessToken: 'access', refreshToken: 'refresh');
      expect(a, b);
    });

    test('разный accessToken — не равны', () {
      const b = AuthTokens(accessToken: 'other', refreshToken: 'refresh');
      expect(a == b, isFalse);
    });

    test('copyWith меняет токен', () {
      final c = a.copyWith(accessToken: 'new');
      expect(c.accessToken, 'new');
      expect(c.refreshToken, 'refresh');
    });
  });
}
