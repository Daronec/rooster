import 'package:rooster/features/profile/domain/entities/profile_entity.dart';

/// DTO для сериализации ProfileEntity в JSON для Cloud.ru API.
///
/// Используется для передачи данных профиля между клиентом и
/// Serverless Functions (GET/PUT /profile).
final class ProfileServerDto {
  /// Создаёт DTO.
  const ProfileServerDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.avatarId,
  });

  /// Создаёт DTO из [ProfileEntity].
  factory ProfileServerDto.fromEntity(ProfileEntity entity) {
    return ProfileServerDto(
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      avatarId: entity.avatarId,
    );
  }

  /// Создаёт DTO из JSON-объекта.
  factory ProfileServerDto.fromJson(Map<String, dynamic> json) {
    return ProfileServerDto(
      userId: json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatarId: json['avatarId'] as String?,
    );
  }

  /// Идентификатор пользователя (совпадает с uid сессии).
  final String userId;

  /// Имя.
  final String firstName;

  /// Фамилия.
  final String lastName;

  /// Идентификатор аватара в облачном хранилище (путь объекта, ключ версии и т.п.).
  final String? avatarId;

  /// Преобразует DTO в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      if (avatarId != null) 'avatarId': avatarId,
    };
  }
}
