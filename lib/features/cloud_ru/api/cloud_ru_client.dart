
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

  /// Загрузить списки задач с cloud.ru.
  Future<List<Map<String, dynamic>>> fetchTaskLists() async {
    try {
      final response = await _dio.get<List<dynamic>>('/task-lists');
      if (response.statusCode == 200) {
        final data = response.data ?? <dynamic>[];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_task_lists_error: $e');
      return [];
    }
  }

  /// Синхронизировать списки задач с cloud.ru.
  Future<bool> syncTaskLists(List<Map<String, dynamic>> lists) async {
    try {
      final response = await _dio.post<bool>('/task-lists/sync', data: lists);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_sync_task_lists_error: $e');
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

  /// Принять приглашение в команду по токену.
  Future<bool> acceptTeamInvitation(String invitationToken) async {
    try {
      final response = await _dio.post<bool>(
        '/teams/accept-invitation',
        data: {
          'invitationToken': invitationToken,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_accept_invitation_error: $e');
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

  /// Получить детали команды с участниками.
  Future<Map<String, dynamic>?> fetchTeamDetails(String teamId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/teams/$teamId');
      return response.statusCode == 200 ? response.data : null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_team_details_error: $e');
      return null;
    }
  }

  /// Обновить роль участника в команде.
  Future<bool> updateMemberRole({
    required String teamId,
    required String memberUserId,
    required List<String> roles,
  }) async {
    try {
      final response = await _dio.put<bool>(
        '/teams/members/$memberUserId/role',
        data: {
          'teamId': teamId,
          'memberUserId': memberUserId,
          'roles': roles,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_member_role_error: $e');
      return false;
    }
  }

  /// Отозвать приглашение в команду.
  Future<bool> revokeInvitation({
    required String teamId,
    required String invitationId,
  }) async {
    try {
      final response = await _dio.delete<bool>(
        '/teams/invitations',
        data: {
          'teamId': teamId,
          'invitationId': invitationId,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_revoke_invitation_error: $e');
      return false;
    }
  }

  /// Отклонить приглашение в команду.
  Future<bool> rejectInvitation({
    required String invitationToken,
  }) async {
    try {
      final response = await _dio.post<bool>(
        '/teams/reject-invitation',
        data: {
          'invitationToken': invitationToken,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_reject_invitation_error: $e');
      return false;
    }
  }

  /// Получить список активных приглашений в команде.
  Future<List<dynamic>?> fetchTeamInvitations(String teamId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/teams/$teamId/invitations');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_team_invitations_error: $e');
      return null;
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

  // ==================== Task CRUD ====================

  /// Загрузить одну задачу по ID.
  Future<Map<String, dynamic>?> fetchTask(String taskId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/tasks/$taskId');
      return response.statusCode == 200 ? response.data : null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_task_error: $e');
      return null;
    }
  }

  /// Создать новую задачу.
  Future<Map<String, dynamic>?> createTask(Map<String, dynamic> task) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/tasks', data: task);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_create_task_error: $e');
      return null;
    }
  }

  /// Обновить задачу (полная замена).
  Future<bool> updateTask(String taskId, Map<String, dynamic> task) async {
    try {
      final response = await _dio.put<bool>('/tasks/$taskId', data: task);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_task_error: $e');
      return false;
    }
  }

  /// Удалить задачу.
  Future<bool> deleteTask(String taskId) async {
    try {
      final response = await _dio.delete<bool>('/tasks/$taskId');
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_task_error: $e');
      return false;
    }
  }

  // ==================== Task List CRUD ====================

  /// Загрузить один список по ID.
  Future<Map<String, dynamic>?> fetchTaskList(String listId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/task-lists/$listId');
      return response.statusCode == 200 ? response.data : null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_task_list_error: $e');
      return null;
    }
  }

  /// Создать новый список.
  Future<Map<String, dynamic>?> createTaskList(Map<String, dynamic> list) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/task-lists', data: list);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_create_task_list_error: $e');
      return null;
    }
  }

  /// Обновить список.
  Future<bool> updateTaskList(String listId, Map<String, dynamic> list) async {
    try {
      final response = await _dio.put<bool>('/task-lists/$listId', data: list);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_task_list_error: $e');
      return false;
    }
  }

  /// Удалить список.
  Future<bool> deleteTaskList(String listId) async {
    try {
      final response = await _dio.delete<bool>('/task-lists/$listId');
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_task_list_error: $e');
      return false;
    }
  }

  // ==================== Plan CRUD ====================

  /// Загрузить один план по ID.
  Future<Map<String, dynamic>?> fetchPlan(String planId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/plans/$planId');
      return response.statusCode == 200 ? response.data : null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_plan_error: $e');
      return null;
    }
  }

  /// Создать новый план.
  Future<Map<String, dynamic>?> createPlan(Map<String, dynamic> plan) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/plans', data: plan);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_create_plan_error: $e');
      return null;
    }
  }

  /// Обновить план.
  Future<bool> updatePlan(String planId, Map<String, dynamic> plan) async {
    try {
      final response = await _dio.put<bool>('/plans/$planId', data: plan);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_plan_error: $e');
      return false;
    }
  }

  /// Удалить план.
  Future<bool> deletePlan(String planId) async {
    try {
      final response = await _dio.delete<bool>('/plans/$planId');
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_plan_error: $e');
      return false;
    }
  }

  // ==================== Material Stock ====================

  /// Загрузить снимок склада материалов.
  Future<Map<String, dynamic>?> fetchMaterialStock() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/material-stock');
      return response.statusCode == 200 ? response.data : null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_material_stock_error: $e');
      return null;
    }
  }

  /// Полная замена склада.
  Future<bool> updateMaterialStock(Map<String, dynamic> stock) async {
    try {
      final response = await _dio.put<bool>('/material-stock', data: stock);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_material_stock_error: $e');
      return false;
    }
  }

  // ==================== Team CRUD ====================

  /// Загрузить все команды.
  Future<List<dynamic>?> fetchTeams() async {
    try {
      final response = await _dio.get<List<dynamic>>('/teams');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_fetch_teams_error: $e');
      return null;
    }
  }

  /// Обновить команду.
  Future<bool> updateTeam(String teamId, Map<String, dynamic> team) async {
    try {
      final response = await _dio.put<bool>('/teams/$teamId', data: team);
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_update_team_error: $e');
      return false;
    }
  }

  /// Удалить команду.
  Future<bool> deleteTeam(String teamId) async {
    try {
      final response = await _dio.delete<bool>('/teams/$teamId');
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_team_error: $e');
      return false;
    }
  }

  /// Удалить участника из команды.
  Future<bool> removeTeamMember({
    required String teamId,
    required String memberUserId,
  }) async {
    try {
      final response = await _dio.delete<bool>(
        '/teams/members',
        data: {
          'teamId': teamId,
          'memberUserId': memberUserId,
        },
      );
      return response.statusCode == 200;
    } on Exception catch (e) {
      _logger.log('cloud_ru_remove_team_member_error: $e');
      return false;
    }
  }

  // ==================== Presigned URLs ====================

  /// Получить URL для загрузки файла (presigned PUT).
  Future<String?> generatePresignedUploadUrl({
    required String bucket,
    required String objectKey,
    required String contentType,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/storage/presigned-upload',
        data: {
          'bucket': bucket,
          'objectKey': objectKey,
          'contentType': contentType,
        },
      );
      if (response.statusCode == 200) {
        return response.data?['url'] as String?;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_presigned_upload_error: $e');
      return null;
    }
  }

  /// Получить URL для скачивания файла (presigned GET).
  Future<String?> generatePresignedDownloadUrl({
    required String bucket,
    required String objectKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/storage/presigned-download',
        data: {
          'bucket': bucket,
          'objectKey': objectKey,
        },
      );
      if (response.statusCode == 200) {
        return response.data?['url'] as String?;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_presigned_download_error: $e');
      return null;
    }
  }

  // ==================== Helper Methods ====================

  /// Обновить IAM token.
  void updateIamToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
  }
}
