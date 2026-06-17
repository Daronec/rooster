// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_storage_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStorageData _$UserStorageDataFromJson(Map<String, dynamic> json) =>
    UserStorageData(
      login: json['login'] as String,
      password: json['password'] as String,
      pinCode: json['pinCode'] as String,
      id: json['id'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserStorageDataToJson(UserStorageData instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
      'pinCode': instance.pinCode,
      'id': instance.id,
      'role': instance.role,
    };
