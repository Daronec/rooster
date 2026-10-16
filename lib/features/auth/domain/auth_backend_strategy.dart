/// Auth strategy selection for social OAuth providers.
enum AuthBackendStrategy {
  /// VK ID OAuth.
  vkId,

  /// Yandex ID OAuth.
  yandexId,
}

/// Resolves the active auth backend strategy.
///
/// [appwriteClientConfigured] is kept for backward compatibility.
AuthBackendStrategy resolveAuthBackendStrategy({
  required bool appwriteClientConfigured,
}) {
  // Default to VK ID as primary auth provider.
  return AuthBackendStrategy.vkId;
}
