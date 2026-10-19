/// Enum for social auth providers.
enum SocialAuthProvider {
  vk('vk'),
  yandex('yandex');

  const SocialAuthProvider(this.name);
  final String name;
}

/// Exception thrown when the user cancels a social auth flow.
///
/// Unlike other exceptions, this should NOT trigger an error snack.
final class SocialAuthCanceledException implements Exception {
  const SocialAuthCanceledException();
}

/// Common result from a social auth sign-in flow.
final class SocialAuthResult {
  const SocialAuthResult({
    required this.provider,
    required this.subject,
    required this.email,
    required this.accessToken,
    this.refreshToken,
    this.phone,
    this.displayName,
    this.avatarUrl,
  });

  final SocialAuthProvider provider;
  final String subject;
  final String email;
  final String accessToken;
  final String? refreshToken;
  final String? phone;
  final String? displayName;
  final String? avatarUrl;

  String get providerName => provider.name;
}
