/// Пользователь приложения для UI и синка (без привязки к Firebase SDK).
final class AppAuthUserEntity {
  /// Создаёт сущность.
  const AppAuthUserEntity({
    required this.uid,
    required this.isAnonymous, this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Стабильный идентификатор (Firebase uid, unionId HMS и т.д.).
  final String uid;

  /// Email, если провайдер его отдал.
  final String? email;

  /// Отображаемое имя.
  final String? displayName;

  /// URL аватара.
  final String? photoUrl;

  /// Анонимная или локальная сессия без привязки к внешнему аккаунту.
  final bool isAnonymous;
}
