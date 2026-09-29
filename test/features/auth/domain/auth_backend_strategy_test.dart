import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';

void main() {
  group('resolveAuthBackendStrategy', () {
    test('returns sberId regardless of client configuration', () {
      expect(
        resolveAuthBackendStrategy(appwriteClientConfigured: true),
        AuthBackendStrategy.sberId,
      );
    });

    test('returns sberId when client is not configured', () {
      expect(
        resolveAuthBackendStrategy(appwriteClientConfigured: false),
        AuthBackendStrategy.sberId,
      );
    });
  });
}
