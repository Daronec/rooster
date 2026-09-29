/// Сущность участника команды.
final class ProfileTeamMemberEntity {
  /// Создаёт сущность участника команды.
  const ProfileTeamMemberEntity({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.roles,
    required this.confirm,
    required this.joinedAtMillis,
  });

  /// ID пользователя в системе авторизации.
  final String userId;

  /// Отображаемое имя.
  final String displayName;

  /// Email пользователя.
  final String email;

  /// Роли пользователя в команде.
  final List<String> roles;

  /// Подтвердил ли пользователь участие (true — ожидает подтверждения).
  final bool confirm;

  /// Время присоединения к команде (millisecondsSinceEpoch).
  final int joinedAtMillis;

  /// Создать из JSON.
  factory ProfileTeamMemberEntity.fromJson(Map<String, dynamic> json) {
    return ProfileTeamMemberEntity(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      confirm: json['confirm'] as bool? ?? false,
      joinedAtMillis: json['joinedAtMillis'] as int? ?? 0,
    );
  }

  /// Преобразовать в JSON.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'roles': roles,
      'confirm': confirm,
      'joinedAtMillis': joinedAtMillis,
    };
  }

  /// Копия с возможностью перезаписи полей.
  ProfileTeamMemberEntity copyWith({
    String? userId,
    String? displayName,
    String? email,
    List<String>? roles,
    bool? confirm,
    int? joinedAtMillis,
  }) {
    return ProfileTeamMemberEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      confirm: confirm ?? this.confirm,
      joinedAtMillis: joinedAtMillis ?? this.joinedAtMillis,
    );
  }
}
