import 'package:rooster/features/profile/domain/entities/profile_team_member_entity.dart';

/// Сущность карточки команды с участниками.
final class ProfileTeamCardEntity {
  /// Создаёт сущность карточки команды.
  const ProfileTeamCardEntity({
    required this.teamId,
    required this.teamName,
    required this.members,
    required this.currentUserMembershipId,
    required this.currentUserIsOwner,
    required this.createdAtMillis,
  });

  /// ID команды.
  final String teamId;

  /// Название команды.
  final String teamName;

  /// Участники команды.
  final List<ProfileTeamMemberEntity> members;

  /// ID членства текущего пользователя в команде.
  final String currentUserMembershipId;

  /// Является ли текущий пользователь владельцем команды.
  final bool currentUserIsOwner;

  /// Время создания команды (millisecondsSinceEpoch).
  final int createdAtMillis;

  /// Создать из JSON.
  factory ProfileTeamCardEntity.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? [];
    final members = membersJson
        .map((m) => ProfileTeamMemberEntity.fromJson(m as Map<String, dynamic>))
        .toList();

    // Определяем currentUserMembershipId и currentUserIsOwner
    // Эти поля должны быть в JSON или определяются по currentUserId
    return ProfileTeamCardEntity(
      teamId: json['teamId'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      members: members,
      currentUserMembershipId:
          json['currentUserMembershipId'] as String? ?? '',
      currentUserIsOwner: json['currentUserIsOwner'] as bool? ?? false,
      createdAtMillis: json['createdAtMillis'] as int? ?? 0,
    );
  }

  /// Преобразовать в JSON.
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'members': members.map((m) => m.toJson()).toList(),
      'currentUserMembershipId': currentUserMembershipId,
      'currentUserIsOwner': currentUserIsOwner,
      'createdAtMillis': createdAtMillis,
    };
  }

  /// Копия с возможностью перезаписи полей.
  ProfileTeamCardEntity copyWith({
    String? teamId,
    String? teamName,
    List<ProfileTeamMemberEntity>? members,
    String? currentUserMembershipId,
    bool? currentUserIsOwner,
    int? createdAtMillis,
  }) {
    return ProfileTeamCardEntity(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      members: members ?? this.members,
      currentUserMembershipId:
          currentUserMembershipId ?? this.currentUserMembershipId,
      currentUserIsOwner: currentUserIsOwner ?? this.currentUserIsOwner,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    );
  }
}
