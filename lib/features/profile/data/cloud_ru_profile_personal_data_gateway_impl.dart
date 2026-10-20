import 'dart:async';

import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/profile/data/dto/profile_server_dto.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';

/// Реализация IProfilePersonalDataGateway через Cloud.ru Serverless Functions.
///
/// Загружает и сохраняет данные профиля (ФИО, аватар) через REST API.
final class CloudRuProfilePersonalDataGatewayImpl
    implements IProfilePersonalDataGateway {
  /// Создаёт gateway.
  CloudRuProfilePersonalDataGatewayImpl({
    required CloudRuClient cloudRuClient,
    required ILogWriter logger,
  })  : _cloudRuClient = cloudRuClient,
        _logger = logger;

  final CloudRuClient _cloudRuClient;
  final ILogWriter _logger;

  /// Локальный кэш загруженного профиля для watch-эмуляции.
  ProfileEntity? _cachedProfile;

  @override
  Stream<ProfileEntity> watchPersonalData(String userId) async* {
    // Serverless Functions не поддерживают real-time streams.
    // Эмулируем stream, эмитируя текущий кэшированный профиль.
    if (_cachedProfile != null && _cachedProfile!.userId == userId) {
      yield _cachedProfile!;
    }
  }

  @override
  Future<ProfileEntity> loadPersonalData(String userId) async {
    try {
      final json = await _cloudRuClient.fetchProfile();
      if (json == null) {
        throw Exception('cloud_ru_profile_not_found');
      }
      final dto = ProfileServerDto.fromJson(json);
      final entity = ProfileEntity(
        userId: dto.userId,
        firstName: dto.firstName,
        lastName: dto.lastName,
        avatarId: dto.avatarId,
      );
      _cachedProfile = entity;
      return entity;
    } on Exception catch (e) {
      _logger.log('cloud_ru_load_personal_data_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final success = await _cloudRuClient.updateProfile({
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'avatarId': _cachedProfile?.avatarId,
      });

      if (!success) {
        throw Exception('cloud_ru_save_personal_data_failed');
      }

      // Обновить кэш
      _cachedProfile = ProfileEntity(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        avatarId: _cachedProfile?.avatarId,
      );
    } on Exception catch (e) {
      _logger.log('cloud_ru_save_personal_data_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncAvatarStorageObjectId({
    required String userId,
    required String avatarStorageObjectId,
  }) async {
    try {
      final success = await _cloudRuClient.updateProfile({
        'userId': userId,
        'avatarId': avatarStorageObjectId,
      });

      if (!success) {
        throw Exception('cloud_ru_sync_avatar_object_failed');
      }

      if (_cachedProfile != null) {
        _cachedProfile = ProfileEntity(
          userId: _cachedProfile!.userId,
          firstName: _cachedProfile!.firstName,
          lastName: _cachedProfile!.lastName,
          avatarId: avatarStorageObjectId,
        );
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_sync_avatar_object_error: $e');
      rethrow;
    }
  }
}
