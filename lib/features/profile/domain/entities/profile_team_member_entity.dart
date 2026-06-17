/// Участник команды Appwrite (членство).
final class ProfileTeamMemberEntity {
  /// Создаёт сущность.
  const ProfileTeamMemberEntity({
    required this.membershipId,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.roles,
    required this.confirm,
  });

  /// Идентификатор членства.
  final String membershipId;

  /// Идентификатор пользователя.
  final String userId;

  /// Имя для отображения (может быть пустым).
  final String displayName;

  /// Email (может быть пустым).
  final String email;

  /// Роли в команде.
  final List<String> roles;

  /// Подтверждённое членство.
  final bool confirm;
}
