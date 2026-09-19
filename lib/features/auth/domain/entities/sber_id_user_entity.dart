import 'package:equatable/equatable.dart';

/// Сущность пользователя, полученная через Sber ID (нативный SDK).
class SberIdUserEntity extends Equatable {
  const SberIdUserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.phone,
    this.accessToken,
    this.refreshToken,
  });

  /// Уникальный идентификатор Sber ID.
  final String id;

  /// Email пользователя.
  final String? email;

  /// Отображаемое имя.
  final String? displayName;

  /// Телефон.
  final String? phone;

  /// Access token для API вызовов.
  final String? accessToken;

  /// Refresh token для обновления access token.
  final String? refreshToken;

  Map<String, Object?> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'phone': phone,
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };

  factory SberIdUserEntity.fromJson(Map<String, Object?> json) {
    return SberIdUserEntity(
      id: json['id'] as String? ?? json['user_id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String? ?? json['first_name'] as String?,
      phone: json['phone'] as String?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, phone, accessToken, refreshToken];
}
