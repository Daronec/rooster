
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';

/// Клиент для взаимодействия с Yandex Cloud (cloud.ru).
///
/// Использует Yandex Serverless Functions для REST API
/// и Yandex Object Storage (S3-compatible) для файлов.
class CloudRuClient {
  /// Создаёт клиент.
  CloudRuClient({
    required String serverlessEndpoint,
    required String storageEndpoint,
    required String? iamToken,
    required ILogWriter logger,
  })  : _serverlessEndpoint = serverlessEndpoint,
        _storageEndpoint = storageEndpoint,
        _iamToken = iamToken,
        _logger = logger,
        _dio = Dio(BaseOptions(
          baseUrl: serverlessEndpoint,
          headers: {'Authorization': 'Bearer $iamToken'},
          contentType: 'application/json',
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (iamToken != null) {
          options.headers['Authorization'] = 'Bearer $iamToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        _logger.log('cloud_ru_api_error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  final String _serverlessEndpoint;
  final String _storageEndpoint;
  final String? _iamToken;
  final ILogWriter _logger;
  final Dio _dio;

  /// Текущий IAM token.
  String? get iamToken => _iamToken;

  /// Endpoint для Serverless Functions.
  String get serverlessEndpoint => _serverlessEndpoint;

  /// Endpoint для Object Storage.
  String get storageEndpoint => _storageEndpoint;

  // ==================== Tasks API ====================

  /// Загрузить задачи с cloud.ru.
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final response = await _dio.get<List<dynamic>>('/tasks');
      if (response.statusCode == 200) {
        final data = response.data ?? <dynamic>[];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_tasks_error: $e');
      return [];
    }
  }

  /// Синхронизировать задачи с cloud.ru.
  Future<bool> syncTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final response = await _dio.post<bool>('/tasks/sync', data: tasks);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_sync_tasks_error: $e');
      return false;
    }
  }

  // ==================== Plans API ====================

  /// Загрузить планы с cloud.ru.
  Future<List<Map<String, dynamic>>> fetchPlans() async {
    try {
      final response = await _dio.get<List<dynamic>>('/plans');
      if (response.statusCode == 200) {
        final data = response.data ?? <dynamic>[];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_plans_error: $e');
      return [];
    }
  }

  /// Синхронизировать планы с cloud.ru.
  Future<bool> syncPlans(List<Map<String, dynamic>> plans) async {
    try {
      final response = await _dio.post<bool>('/plans/sync', data: plans);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_sync_plans_error: $e');
      return false;
    }
  }

  // ==================== Profile API ====================

  /// Загрузить профиль с cloud.ru.
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/profile');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_profile_error: $e');
      return null;
    }
  }

  /// Обновить профиль на cloud.ru.
  Future<bool> updateProfile(Map<String, dynamic> profile) async {
    try {
      final response = await _dio.put<bool>('/profile', data: profile);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_profile_error: $e');
      return false;
    }
  }

  // ==================== Teams API ====================

  /// Загрузить команды пользователя с cloud.ru.
  Future<List<dynamic>?> fetchTeamsForUser(String userId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/teams', queryParameters: {
        'userId': userId,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_teams_error: $e');
      return null;
    }
  }

  /// Создать новую команду на cloud.ru.
  Future<bool> createTeam(Map<String, dynamic> teamData) async {
    try {
      final response = await _dio.post<bool>('/teams', data: teamData);
      return response.statusCode == 200 || response.statusCode == 201;
    } on Exception catch (e) {
      _logger.log('cloud_ru_create_team_error: $e');
      return false;
    }
  }

  /// Пригласить участника в команду.
  Future<bool> inviteToTeam({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  }) async {
    try {
      final response = await _dio.post<bool>(
        '/teams/invite',
        data: {
          'teamId': teamId,
          'email': email,
          'invitationReturnUrl': invitationReturnUrl,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_invite_to_team_error: $e');
      return false;
    }
  }

  /// Покинуть команду.
  Future<bool> leaveTeam({
    required String teamId,
    required String membershipId,
  }) async {
    try {
      final response = await _dio.delete<bool>(
        '/teams/leave',
        data: {
          'teamId': teamId,
          'membershipId': membershipId,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_leave_team_error: $e');
      return false;
    }
  }

  // ==================== Object Storage (S3) ====================

  /// Загрузить файл в Object Storage.
  Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String objectKey,
  }) async {
    try {
      final url = '$_storageEndpoint/$bucket/$objectKey';
      final fileBytes = await file.readAsBytes();
      
      final response = await Dio().put<String>(
        url,
        data: fileBytes,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_iamToken',
            'Content-Type': 'application/octet-stream',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        debugPrint('cloud_ru_upload_file_success: $objectKey');
        return url;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_upload_file_error: $e');
      return null;
    }
  }

  /// Получить URL для скачивания файла.
  String? getDownloadUrl({
    required String bucket,
    required String objectKey,
  }) {
    try {
      return '$_storageEndpoint/$bucket/$objectKey';
    } on Exception {
      return null;
    }
  }

  // ==================== Helper Methods ====================

  /// Обновить IAM token.
  void updateIamToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
  }
}
