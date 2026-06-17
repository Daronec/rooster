/// Профиль пользователя в облаке (ФИО и ссылка на аватар).
final class ProfileEntity {
  /// Создаёт сущность.
  const ProfileEntity({
    required this.userId,
    this.firstName = '',
    this.lastName = '',
    this.avatarId,
  });

  /// Идентификатор пользователя (совпадает с uid сессии).
  final String userId;

  /// Имя.
  final String firstName;

  /// Фамилия.
  final String lastName;

  /// Идентификатор аватара в облачном хранилище (путь объекта, ключ версии и т.п.).
  final String? avatarId;
}
