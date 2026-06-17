import 'dart:typed_data';

import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/profile/data/hms_avatar_file_store.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Аватар при ветке Appwrite: файл в каталоге приложения и путь в [SharedPreferences].
///
/// Облачный Appwrite Storage не используется (отдельный bucket не требуется).
final class AppwriteProfileAvatarGatewayImpl implements IProfileAvatarGateway {
  /// Создаёт шлюз.
  AppwriteProfileAvatarGatewayImpl({
    required SharedPreferences sharedPreferences,
    required ILogWriter logger,
  }) : _prefs = sharedPreferences,
       _logger = logger;

  static const String _pathKeyPrefix = 'appwrite_profile_avatar_path_v1_';

  final SharedPreferences _prefs;
  final ILogWriter _logger;

  @override
  Future<String?> getPersistedLocalAvatarPath(String userId) async {
    final path = _prefs.getString('$_pathKeyPrefix$userId');
    if (path == null || path.isEmpty) {
      return null;
    }
    final exists = await hmsAvatarFileExists(path);
    if (!exists) {
      await _prefs.remove('$_pathKeyPrefix$userId');
      return null;
    }
    return path;
  }

  @override
  Future<void> saveAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    if (imageBytes.isEmpty) {
      throw ArgumentError.value(imageBytes, 'imageBytes', 'empty');
    }
    _logger.log(
      'appwrite_profile_avatar_save_start userId=${_shortId(userId)} '
      'bytes=${imageBytes.length}',
    );
    try {
      final path = await saveHmsAvatarFile(userId, imageBytes);
      await _prefs.setString('$_pathKeyPrefix$userId', path);
      _logger.log('appwrite_profile_avatar_save_ok pathLen=${path.length}');
    } on Object catch (error) {
      _logger.log('appwrite_profile_avatar_save_fail $error');
      rethrow;
    }
  }

  static String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }
    return value.substring(0, 8);
  }
}
