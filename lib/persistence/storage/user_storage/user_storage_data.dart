import 'package:json_annotation/json_annotation.dart';

part 'user_storage_data.g.dart';

/// Данные пользователя для сериализации в локальное хранилище.
@JsonSerializable()
class UserStorageData {

  /// Создаёт экземпляр [UserStorageData].
  const UserStorageData({
    required this.login,
    required this.password,
    required this.pinCode,
    required this.id,
    required this.role,
  });

  /// Десериализация из JSON.
  factory UserStorageData.fromJson(Map<String, dynamic> json) =>
      _$UserStorageDataFromJson(json);
  /// Логин.
  final String login;

  /// Пароль.
  ///
  /// Удалить при подключении к API авторизации.
  final String password;

  /// Пин-код.
  final String pinCode;

  /// Уникальный идентификатор пользователя (UUID), выдаётся при авторизации.
  final String id;

  /// Имя роли: значение `UserRole.name` (например `engineer`, `owner`).
  final String role;

  /// Сериализация в JSON.
  Map<String, dynamic> toJson() => _$UserStorageDataToJson(this);
}
