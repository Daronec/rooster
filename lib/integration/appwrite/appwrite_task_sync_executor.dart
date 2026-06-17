import 'dart:convert';
import 'dart:io' show Directory, File;

// ignore_for_file: deprecated_member_use

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/core/sync/sync_auth_required_exception.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/tasks/data/gateways/task_image_compressor.dart';
import 'package:rooster/features/planning/data/mappers/planning_plan_entity_codec.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/tasks/data/mappers/material_stock_snapshot_codec.dart';
import 'package:rooster/features/tasks/data/mappers/task_entity_codec.dart';
import 'package:rooster/features/tasks/data/mappers/task_list_entity_codec.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/integration/appwrite/appwrite_sync_document_payload_keys.dart';

/// Исходящая синхронизация очереди в Appwrite Databases и Storage.
final class AppwriteTaskSyncExecutor implements ISyncRemoteExecutor {
  /// Создаёт исполнитель.
  AppwriteTaskSyncExecutor({
    required Client client,
    required AppwriteEnvConfig envConfig,
    required IAuthGateway authGateway,
    required ILogWriter logger,
    required Future<TaskEntity?> Function(String taskId) loadTaskLocal,
    required Future<TaskListEntity?> Function(String listId) loadListLocal,
    required Future<PlanningPlanEntity?> Function(String planId) loadPlanLocal,
    required Future<MaterialStockSnapshotEntity?> Function()
        loadMaterialStockSnapshotLocal,
    Future<void> Function(String taskId)? onTaskPushSucceeded,
  }) : _databases = Databases(client),
       _storage = Storage(client),
       _envConfig = envConfig,
       _authGateway = authGateway,
       _logger = logger,
       _loadTaskLocal = loadTaskLocal,
       _loadListLocal = loadListLocal,
       _loadPlanLocal = loadPlanLocal,
       _loadMaterialStockSnapshotLocal = loadMaterialStockSnapshotLocal,
       _onTaskPushSucceeded = onTaskPushSucceeded;

  final Databases _databases;
  final Storage _storage;
  final AppwriteEnvConfig _envConfig;
  final IAuthGateway _authGateway;
  final ILogWriter _logger;
  final Future<TaskEntity?> Function(String taskId) _loadTaskLocal;
  final Future<TaskListEntity?> Function(String listId) _loadListLocal;
  final Future<PlanningPlanEntity?> Function(String planId) _loadPlanLocal;
  final Future<MaterialStockSnapshotEntity?> Function()
      _loadMaterialStockSnapshotLocal;
  final Future<void> Function(String taskId)? _onTaskPushSucceeded;

  AppwriteEnvConfig get _env => _envConfig;

  static String _shortUserId(String userId) =>
      userId.length <= 8 ? userId : userId.substring(0, 8);

  static String _basename(String filePath) {
    final forward = filePath.lastIndexOf('/');
    final backward = filePath.lastIndexOf(r'\');
    final cut = forward > backward ? forward : backward;
    return cut >= 0 ? filePath.substring(cut + 1) : filePath;
  }

  List<String> _ownerDocumentPermissions(String userId) {
    final role = Role.user(userId);
    return <String>[
      Permission.read(role),
      Permission.update(role),
      Permission.delete(role),
    ];
  }

  List<String> _taskDocumentPermissions({
    required String ownerUserId,
    required String? executorUserId,
    required String? executorTeamId,
    required String? observerUserId,
    required String? observerTeamId,
  }) {
    final permissions = <String>[
      ..._ownerDocumentPermissions(ownerUserId),
    ];
    final executor = executorUserId?.trim();
    if (executor != null && executor.isNotEmpty && executor != ownerUserId) {
      final role = Role.user(executor);
      permissions.add(Permission.read(role));
      permissions.add(Permission.update(role));
    }
    final observer = observerUserId?.trim();
    if (observer != null && observer.isNotEmpty && observer != ownerUserId) {
      permissions.add(Permission.read(Role.user(observer)));
    }
    final sharedTeamIds = <String>{
      if (executorTeamId != null && executorTeamId.trim().isNotEmpty)
        executorTeamId.trim(),
      if (observerTeamId != null && observerTeamId.trim().isNotEmpty)
        observerTeamId.trim(),
    };
    for (final sharedTeamId in sharedTeamIds) {
      final role = Role.team(sharedTeamId);
      permissions.add(Permission.read(role));
    }
    return permissions;
  }

  @override
  Future<Result<void, Failure<Exception>>> execute(
    SyncOperation operation,
  ) async {
    final user = _authGateway.currentUser;
    if (user == null) {
      return Result.failed(
        Failure(
          original: SyncAuthRequiredException(),
          trace: StackTrace.current,
        ),
      );
    }
    if (user.isAnonymous) {
      if (kDebugMode) {
        _logger.log(
          'appwrite_sync_skip_anonymous ${operation.type.name} op=${operation.id}',
        );
      }
      return const Result.ok(null);
    }
    final remoteUserId = user.uid;
    try {
      switch (operation.type) {
        case SyncOperationType.upsertTask:
          return await _upsertTask(remoteUserId, operation);
        case SyncOperationType.deleteTask:
          return await _deleteTask(remoteUserId, operation);
        case SyncOperationType.upsertTaskList:
          return await _upsertList(remoteUserId, operation);
        case SyncOperationType.deleteTaskList:
          return await _deleteList(remoteUserId, operation);
        case SyncOperationType.upsertPlan:
          return await _upsertPlan(remoteUserId, operation);
        case SyncOperationType.deletePlan:
          return await _deletePlan(remoteUserId, operation);
        case SyncOperationType.upsertMaterialStock:
          return await _upsertMaterialStock(remoteUserId, operation);
        case SyncOperationType.uploadTaskImage:
          return await _uploadImage(remoteUserId, operation);
        case SyncOperationType.patchTaskStatus:
          return await _patchStatus(remoteUserId, operation);
      }
    } on AppwriteException catch (exception, trace) {
      _logger.log(
        'appwrite_sync_fail type=${operation.type.name} op=${operation.id} '
        'code=${exception.code} message=${exception.message}',
      );
      return Result.failed(
        Failure(original: exception, trace: trace),
      );
    } on Exception catch (exception, trace) {
      _logger.exception(exception, trace);
      return Result.failed(Failure(original: exception, trace: trace));
    }
  }

  Map<String, dynamic> _taskDocumentData({
    required String userId,
    required TaskEntity task,
  }) {
    final map = Map<String, dynamic>.from(TaskEntityCodec.toMap(task));
    map['version'] = task.contentRevision;
    final sharedWith = <String>{
      if (task.executorUserId != null && task.executorUserId!.trim().isNotEmpty)
        task.executorUserId!.trim(),
      if (task.observerUserId != null && task.observerUserId!.trim().isNotEmpty)
        task.observerUserId!.trim(),
    }.toList(growable: false);
    return <String, dynamic>{
      AppwriteSyncDocumentPayloadKeys.userId: userId,
      AppwriteSyncDocumentPayloadKeys.sharedWith: sharedWith,
      AppwriteSyncDocumentPayloadKeys.documentJson: jsonEncode(map),
      AppwriteSyncDocumentPayloadKeys.updatedAtIso:
          DateTime.fromMillisecondsSinceEpoch(
            task.updatedAtMillis,
            isUtc: true,
          ).toIso8601String(),
      AppwriteSyncDocumentPayloadKeys.contentRevision: task.contentRevision,
    };
  }

  Map<String, dynamic> _planDocumentData({
    required String userId,
    required PlanningPlanEntity plan,
  }) {
    final map = Map<String, dynamic>.from(PlanningPlanEntityCodec.toMap(plan));
    map['version'] = plan.contentRevision;
    return <String, dynamic>{
      AppwriteSyncDocumentPayloadKeys.userId: userId,
      AppwriteSyncDocumentPayloadKeys.documentJson: jsonEncode(map),
      AppwriteSyncDocumentPayloadKeys.updatedAtIso:
          DateTime.fromMillisecondsSinceEpoch(
            plan.updatedAtMillis,
            isUtc: true,
          ).toIso8601String(),
      AppwriteSyncDocumentPayloadKeys.contentRevision: plan.contentRevision,
    };
  }

  Map<String, dynamic> _materialStockDocumentData({
    required String userId,
    required MaterialStockSnapshotEntity snapshot,
  }) {
    final map = Map<String, dynamic>.from(
      MaterialStockSnapshotCodec.toMap(snapshot),
    );
    map['version'] = snapshot.contentRevision;
    return <String, dynamic>{
      AppwriteSyncDocumentPayloadKeys.userId: userId,
      AppwriteSyncDocumentPayloadKeys.documentJson: jsonEncode(map),
      AppwriteSyncDocumentPayloadKeys.updatedAtIso:
          DateTime.fromMillisecondsSinceEpoch(
            snapshot.updatedAtMillis,
            isUtc: true,
          ).toIso8601String(),
      AppwriteSyncDocumentPayloadKeys.contentRevision: snapshot.contentRevision,
    };
  }

  Map<String, dynamic> _listDocumentData({
    required String userId,
    required TaskListEntity list,
  }) {
    final map = Map<String, dynamic>.from(TaskListEntityCodec.toMap(list));
    map['version'] = list.contentRevision;
    return <String, dynamic>{
      AppwriteSyncDocumentPayloadKeys.userId: userId,
      AppwriteSyncDocumentPayloadKeys.documentJson: jsonEncode(map),
      AppwriteSyncDocumentPayloadKeys.updatedAtIso:
          DateTime.fromMillisecondsSinceEpoch(
            list.updatedAtMillis,
            isUtc: true,
          ).toIso8601String(),
      AppwriteSyncDocumentPayloadKeys.contentRevision: list.contentRevision,
    };
  }

  Future<Result<void, Failure<Exception>>> _upsertTask(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final taskId = operation.payload['taskId'] as String?;
    if (taskId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload taskId'),
          trace: StackTrace.current,
        ),
      );
    }
    final local = await _loadTaskLocal(taskId);
    if (local == null) {
      return const Result.ok(null);
    }
    final ownerUserId = local.ownerUserId?.trim().isNotEmpty ?? false
        ? local.ownerUserId!.trim()
        : remoteUserId;
    await _databases.upsertDocument(
      databaseId: _env.syncDatabaseId,
      collectionId: _env.syncTasksCollectionId,
      documentId: taskId,
      data: _taskDocumentData(userId: ownerUserId, task: local),
      permissions: _taskDocumentPermissions(
        ownerUserId: ownerUserId,
        executorUserId: local.executorUserId,
        executorTeamId: local.executorTeamId,
        observerUserId: local.observerUserId,
        observerTeamId: local.observerTeamId,
      ),
    );
    _logger.log('appwrite_sync_upsert_task_ok taskId=$taskId');
    final ack = _onTaskPushSucceeded;
    if (ack != null) {
      await ack(taskId);
    }
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _deleteTask(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final taskId = operation.payload['taskId'] as String?;
    if (taskId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload taskId'),
          trace: StackTrace.current,
        ),
      );
    }
    try {
      await _databases.deleteDocument(
        databaseId: _env.syncDatabaseId,
        collectionId: _env.syncTasksCollectionId,
        documentId: taskId,
      );
      _logger.log('appwrite_sync_delete_task_ok taskId=$taskId');
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        _logger.log('appwrite_sync_delete_task_missing taskId=$taskId');
        return const Result.ok(null);
      }
      rethrow;
    }
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _upsertList(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final listId = operation.payload['listId'] as String?;
    if (listId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload listId'),
          trace: StackTrace.current,
        ),
      );
    }
    final local = await _loadListLocal(listId);
    if (local == null) {
      return const Result.ok(null);
    }
    await _databases.upsertDocument(
      databaseId: _env.syncDatabaseId,
      collectionId: _env.syncListsCollectionId,
      documentId: listId,
      data: _listDocumentData(userId: remoteUserId, list: local),
      permissions: _ownerDocumentPermissions(remoteUserId),
    );
    _logger.log('appwrite_sync_upsert_list_ok listId=$listId');
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _deleteList(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final listId = operation.payload['listId'] as String?;
    if (listId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload listId'),
          trace: StackTrace.current,
        ),
      );
    }
    try {
      await _databases.deleteDocument(
        databaseId: _env.syncDatabaseId,
        collectionId: _env.syncListsCollectionId,
        documentId: listId,
      );
      _logger.log(
        'appwrite_sync_delete_list_ok user=${_shortUserId(remoteUserId)} listId=$listId',
      );
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        _logger.log('appwrite_sync_delete_list_missing listId=$listId');
        return const Result.ok(null);
      }
      rethrow;
    }
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _upsertPlan(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final planId = operation.payload['planId'] as String?;
    if (planId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload planId'),
          trace: StackTrace.current,
        ),
      );
    }
    final local = await _loadPlanLocal(planId);
    if (local == null) {
      return const Result.ok(null);
    }
    await _databases.upsertDocument(
      databaseId: _env.syncDatabaseId,
      collectionId: _env.syncPlansCollectionId,
      documentId: planId,
      data: _planDocumentData(userId: remoteUserId, plan: local),
      permissions: _ownerDocumentPermissions(remoteUserId),
    );
    _logger.log('appwrite_sync_upsert_plan_ok planId=$planId');
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _deletePlan(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final planId = operation.payload['planId'] as String?;
    if (planId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload planId'),
          trace: StackTrace.current,
        ),
      );
    }
    try {
      await _databases.deleteDocument(
        databaseId: _env.syncDatabaseId,
        collectionId: _env.syncPlansCollectionId,
        documentId: planId,
      );
      _logger.log('appwrite_sync_delete_plan_ok planId=$planId');
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        _logger.log('appwrite_sync_delete_plan_missing planId=$planId');
        return const Result.ok(null);
      }
      rethrow;
    }
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _upsertMaterialStock(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final local = await _loadMaterialStockSnapshotLocal();
    if (local == null) {
      return const Result.ok(null);
    }
    await _databases.upsertDocument(
      databaseId: _env.syncDatabaseId,
      collectionId: _env.syncMaterialsCollectionId,
      documentId: remoteUserId,
      data: _materialStockDocumentData(userId: remoteUserId, snapshot: local),
      permissions: _ownerDocumentPermissions(remoteUserId),
    );
    _logger.log(
      'appwrite_sync_upsert_material_stock_ok user=${_shortUserId(remoteUserId)}',
    );
    return const Result.ok(null);
  }

  Future<Result<void, Failure<Exception>>> _uploadImage(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    if (kIsWeb) {
      return Result.failed(
        Failure(
          original: Exception('Загрузка файла на web не реализована'),
          trace: StackTrace.current,
        ),
      );
    }
    final taskId = operation.payload['taskId'] as String?;
    final path = operation.payload['localPath'] as String?;
    if (taskId == null || path == null) {
      return Result.failed(
        Failure(
          original: Exception('payload taskId/localPath'),
          trace: StackTrace.current,
        ),
      );
    }
    final file = File(path);
    if (!file.existsSync()) {
      return Result.failed(
        Failure(
          original: Exception('Файл не найден'),
          trace: StackTrace.current,
        ),
      );
    }
    final uploadFile = await _createCompressedUploadFile(file);
    final fileId = ID.unique();
    final role = Role.user(remoteUserId);
    final filePermissions = <String>[
      Permission.read(role),
      Permission.update(role),
      Permission.delete(role),
    ];
    try {
      await _storage.createFile(
        bucketId: _env.syncTaskImagesBucketId,
        fileId: fileId,
        file: InputFile.fromPath(
          path: uploadFile.path,
          filename: _basename(uploadFile.path),
          contentType: 'image/jpeg',
        ),
        permissions: filePermissions,
      );
    } finally {
      if (uploadFile.path != file.path && uploadFile.existsSync()) {
        await uploadFile.delete();
      }
    }
    _logger.log(
      'appwrite_sync_upload_task_image_ok taskId=$taskId fileId=$fileId',
    );
    return const Result.ok(null);
  }

  Future<File> _createCompressedUploadFile(File sourceFile) async {
    final compressionResult = await TaskImageCompressor.compressToJpeg(
      await sourceFile.readAsBytes(),
    );
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final uploadFile = File(
      '${Directory.systemTemp.path}/rooster_task_image_$stamp.jpg',
    );
    await uploadFile.writeAsBytes(compressionResult.bytes, flush: true);
    return uploadFile;
  }

  Future<Result<void, Failure<Exception>>> _patchStatus(
    String remoteUserId,
    SyncOperation operation,
  ) async {
    final taskId = operation.payload['taskId'] as String?;
    if (taskId == null) {
      return Result.failed(
        Failure(
          original: Exception('payload taskId'),
          trace: StackTrace.current,
        ),
      );
    }
    final local = await _loadTaskLocal(taskId);
    if (local == null) {
      return const Result.ok(null);
    }
    return _upsertTask(remoteUserId, operation);
  }
}
