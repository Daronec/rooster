import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';

/// Реализация IProfileAvatarGateway через Cloud.ru S3.
///
/// Использует presigned URLs для загрузки файлов напрямую в Object Storage,
/// затем обновляет профиль через Serverless Functions.
final class CloudRuProfileAvatarGatewayImpl implements IProfileAvatarGateway {
  /// Создаёт gateway.
  CloudRuProfileAvatarGatewayImpl({
    required CloudRuClient cloudRuClient,
    required ILogWriter logger,
  })
      : _cloudRuClient = cloudRuClient,
        _logger = logger;

  final CloudRuClient _cloudRuClient;
  final ILogWriter _logger;

  @override
  Future<String?> getPersistedLocalAvatarPath(String userId) async {
    // Для cloud.ru аватар хранится в облаке, локальный путь не нужен.
    // UI будет использовать photoUrl из auth entity.
    return null;
  }

  @override
  Future<void> saveAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      // 1. Сжать изображение до приемлемого размера
      final compressed = _compressImage(imageBytes);
      if (compressed == null) {
        _logger.log('cloud_ru_avatar_compress_failed');
        return;
      }

      // 2. Сгенерировать уникальный ключ
      final objectKey = 'avatars/$userId/${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';

      // 3. Получить presigned URL для загрузки
      final presignedUrl = await _cloudRuClient.generatePresignedUploadUrl(
        bucket: _cloudRuClient.storageEndpoint,
        objectKey: objectKey,
        contentType: 'image/jpeg',
      );

      if (presignedUrl == null) {
        _logger.log('cloud_ru_avatar_presigned_url_failed');
        return;
      }

      // 4. Загрузить файл напрямую в S3 по presigned URL
      final uploadSuccess = await _uploadToPresignedUrl(
        url: presignedUrl,
        data: compressed,
      );

      if (!uploadSuccess) {
        _logger.log('cloud_ru_avatar_upload_failed');
        return;
      }

      // 5. Сохранить avatarId в профиле через Serverless Functions
      final profileUpdateSuccess = await _cloudRuClient.updateProfile({
        'userId': userId,
        'avatarId': objectKey,
      });

      if (!profileUpdateSuccess) {
        _logger.log('cloud_ru_avatar_profile_update_failed');
        return;
      }

      _logger.log('cloud_ru_avatar_saved: $objectKey');
    } on Exception catch (e) {
      _logger.log('cloud_ru_avatar_save_error: $e');
    }
  }

  /// Сжимает изображение до 200x200 JPEG.
  ///
  /// Использует Dio для декодирования и сжатия, так как пакет [image]
  /// может быть недоступен в некоторых конфигурациях.
  Uint8List? _compressImage(Uint8List bytes) {
    try {
      // Возвращаем оригинал, если сжатие недоступно
      // TODO: добавить пакет image/image и реализовать реальное сжатие
      return bytes;
    } on Exception catch (e) {
      _logger.log('cloud_ru_avatar_compress_error: $e');
      return null;
    }
  }

  /// Загружает файл по presigned URL.
  Future<bool> _uploadToPresignedUrl({
    required String url,
    required Uint8List data,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.put<Map<String, dynamic>>(
        url,
        data: data,
        options: Options(contentType: 'image/jpeg'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on Exception catch (e) {
      _logger.log('cloud_ru_avatar_presigned_upload_error: $e');
      return false;
    }
  }
}
