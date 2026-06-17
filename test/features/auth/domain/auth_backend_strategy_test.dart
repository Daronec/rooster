import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';

void main() {
  group('resolveAuthBackendStrategy', () {
    test('returns appwrite when client is configured', () {
      expect(
        resolveAuthBackendStrategy(appwriteClientConfigured: true),
        AuthBackendStrategy.appwrite,
      );
    });

    test('returns offlineOnly when client is not configured', () {
      expect(
        resolveAuthBackendStrategy(appwriteClientConfigured: false),
        AuthBackendStrategy.offlineOnly,
      );
    });
  });
}
