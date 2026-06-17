import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';

/// Персональные данные из [Account] Appwrite (поле `name` аккаунта).
final class AppwriteProfilePersonalDataGatewayImpl
    implements IProfilePersonalDataGateway {
  /// Создаёт шлюз.
  AppwriteProfilePersonalDataGatewayImpl({
    required Account account,
    required ILogWriter logger,
  }) : _account = account,
       _logger = logger;

  final Account _account;
  final ILogWriter _logger;

  static const int _maxNameLength = 128;

  static ProfileEntity _mapUser(aw_models.User user) {
    return ProfileEntity(
      userId: user.$id,
      firstName: user.name.trim(),
    );
  }

  @override
  Future<ProfileEntity> loadPersonalData(String userId) async {
    _logger.log(
      'appwrite_profile_personal_load_start userId=${_shortId(userId)}',
    );
    try {
      final user = await _account.get();
      if (user.$id != userId) {
        _logger.log(
          'appwrite_profile_personal_user_mismatch expected=${_shortId(userId)} '
          'got=${_shortId(user.$id)}',
        );
      }
      final entity = _mapUser(user);
      _logger.log('appwrite_profile_personal_load_ok');
      return entity;
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_profile_personal_load_fail code=${error.code} '
        'message=${error.message}',
      );
      rethrow;
    }
  }

  @override
  Stream<ProfileEntity> watchPersonalData(String userId) async* {
    yield await loadPersonalData(userId);
  }

  @override
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName, // Appwrite: только [Account.updateName]; фамилия не хранится.
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'empty');
    }
    final trimmed = firstName.trim();
    if (trimmed.length > _maxNameLength) {
      throw ArgumentError.value(
        firstName,
        'firstName',
        'max length $_maxNameLength',
      );
    }
    _logger.log(
      'appwrite_profile_personal_save_start nameLen=${trimmed.length}',
    );
    try {
      await _account.updateName(name: trimmed);
      _logger.log('appwrite_profile_personal_save_ok');
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_profile_personal_save_fail code=${error.code} '
        'message=${error.message}',
      );
      rethrow;
    }
  }

  @override
  Future<void> syncAvatarStorageObjectId({
    required String userId,
    required String avatarStorageObjectId,
  }) async {
    if (kDebugMode) {
      _logger.log('appwrite_profile_personal_avatar_sync_skip');
    }
  }

  static String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }
    return value.substring(0, 8);
  }
}
