/// Пользователь Sber ID для UI и синка (без привязки к Firebase SDK).
final class SberIdUserEntity {
  /// Создаёт сущность.
  const SberIdUserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.phone,
  });

  /// Стабильный идентификатор пользователя в Sber ID.
  final String id;

  /// Email, если провайдер его отдал.
  final String? email;

  /// Отображаемое имя.
  final String? displayName;

  /// Телефон в формате E.164.
  final String? phone;
}
