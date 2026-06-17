// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/planning/data/mappers/planning_plan_entity_codec.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/tasks/data/mappers/material_stock_snapshot_codec.dart';
import 'package:rooster/features/tasks/data/mappers/task_entity_codec.dart';
import 'package:rooster/features/tasks/data/mappers/task_list_entity_codec.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/integration/appwrite/appwrite_sync_document_payload_keys.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';

const int _kAppwritePullPageSize = 100;

/// Загрузка документов из Appwrite и merge в локальные репозитории.
final class AppwriteTaskCloudPuller {
  /// Создаёт puller.
  AppwriteTaskCloudPuller({
    required Databases databases,
    required AppwriteEnvConfig envConfig,
    required ITasksRepository tasksRepository,
    required ITaskListsRepository taskListsRepository,
    required IPlanningRepository planningRepository,
    required IMaterialStockRepository materialStockRepository,
    required ILogWriter logger,
  })  : _databases = databases,
        _envConfig = envConfig,
        _tasksRepository = tasksRepository,
        _taskListsRepository = taskListsRepository,
        _planningRepository = planningRepository,
        _materialStockRepository = materialStockRepository,
        _logger = logger;

  final Databases _databases;
  final AppwriteEnvConfig _envConfig;
  final ITasksRepository _tasksRepository;
  final ITaskListsRepository _taskListsRepository;
  final IPlanningRepository _planningRepository;
  final IMaterialStockRepository _materialStockRepository;
  final ILogWriter _logger;

  /// Списки, затем задачи (списки — родительская сущность по смыслу UI).
  Future<void> pullAllForUser(String userId) async {
    if (kDebugMode) {
      _logger.log('appwrite_pull_all_start userId=${_shortUserId(userId)}');
    }
    await _pullCollection(
      userId: userId,
      collectionId: _envConfig.syncListsCollectionId,
      parse: _parseListDocument,
      apply: _taskListsRepository.mergeRemoteListIfNewer,
    );
    await _pullCollection(
      userId: userId,
      collectionId: _envConfig.syncTasksCollectionId,
      parse: _parseTaskDocument,
      apply: _tasksRepository.mergeRemoteTaskIfNewer,
    );
    await _pullCollection(
      userId: userId,
      collectionId: _envConfig.syncPlansCollectionId,
      parse: _parsePlanDocument,
      apply: _planningRepository.mergeRemotePlanIfNewer,
    );
    await _pullMaterialStock(userId: userId);
    _logger.log('appwrite_pull_all_done userId=${_shortUserId(userId)}');
  }

  Future<void> _pullCollection<T>({
    required String userId,
    required String collectionId,
    required T? Function(aw_models.Document doc) parse,
    required Future<void> Function(T entity) apply,
  }) async {
    if (kDebugMode) {
      _logger.log(
        'appwrite_pull_collection_start userId=${_shortUserId(userId)} collection=$collectionId',
      );
    }
    final queriesBase = _queriesBaseForCollection(
      userId: userId,
      collectionId: collectionId,
    );
    var cursorQueries = queriesBase;
    var seen = 0;
    var applied = 0;
    var skipped = 0;
    while (true) {
      final list = await _databases.listDocuments(
        databaseId: _envConfig.syncDatabaseId,
        collectionId: collectionId,
        queries: cursorQueries,
      );
      seen += list.documents.length;
      for (final doc in list.documents) {
        final entity = parse(doc);
        if (entity == null) {
          skipped++;
          if (kDebugMode) {
            _logger.log(
              'appwrite_pull_skip_parse collection=$collectionId doc=${doc.$id}',
            );
          }
          continue;
        }
        await apply(entity);
        applied++;
      }
      if (list.documents.length < _kAppwritePullPageSize) {
        break;
      }
      final lastId = list.documents.last.$id;
      cursorQueries = <String>[
        ...queriesBase,
        Query.cursorAfter(lastId),
      ];
      if (kDebugMode) {
        _logger.log(
          'appwrite_pull_page_next userId=${_shortUserId(userId)} collection=$collectionId cursorAfter=$lastId',
        );
      }
    }
    if (kDebugMode) {
      _logger.log(
        'appwrite_pull_collection_done userId=${_shortUserId(userId)} collection=$collectionId '
        'seen=$seen applied=$applied skipped=$skipped',
      );
    }
  }

  List<String> _queriesBaseForCollection({
    required String userId,
    required String collectionId,
  }) {
    if (collectionId == _envConfig.syncTasksCollectionId) {
      return <String>[
        Query.or(<String>[
          Query.equal(AppwriteSyncDocumentPayloadKeys.userId, userId),
          Query.containsAny(
            AppwriteSyncDocumentPayloadKeys.sharedWith,
            <dynamic>[userId],
          ),
        ]),
        Query.limit(_kAppwritePullPageSize),
      ];
    }
    return <String>[
      Query.equal(AppwriteSyncDocumentPayloadKeys.userId, userId),
      Query.limit(_kAppwritePullPageSize),
    ];
  }

  TaskEntity? _parseTaskDocument(aw_models.Document doc) {
    final raw = doc.data[AppwriteSyncDocumentPayloadKeys.documentJson];
    if (raw is! String) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return TaskEntityCodec.fromMap(Map<String, dynamic>.from(decoded));
    } on Object catch (error, trace) {
      if (kDebugMode) {
        _logger.log('appwrite_pull_task_json_fail doc=${doc.$id} $error');
        _logger.exception(error, trace);
      }
      return null;
    }
  }

  Future<void> _pullMaterialStock({required String userId}) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _envConfig.syncDatabaseId,
        collectionId: _envConfig.syncMaterialsCollectionId,
        documentId: userId,
      );
      final snapshot = _parseMaterialStockDocument(doc);
      if (snapshot != null) {
        await _materialStockRepository.mergeRemoteStockIfNewer(snapshot);
      }
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        if (kDebugMode) {
          _logger.log(
            'appwrite_pull_material_stock_missing userId=${_shortUserId(userId)}',
          );
        }
        return;
      }
      rethrow;
    }
  }

  PlanningPlanEntity? _parsePlanDocument(aw_models.Document doc) {
    final raw = doc.data[AppwriteSyncDocumentPayloadKeys.documentJson];
    if (raw is! String) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return PlanningPlanEntityCodec.fromMap(Map<String, dynamic>.from(decoded));
    } on Object catch (error, trace) {
      if (kDebugMode) {
        _logger.log('appwrite_pull_plan_json_fail doc=${doc.$id} $error');
        _logger.exception(error, trace);
      }
      return null;
    }
  }

  MaterialStockSnapshotEntity? _parseMaterialStockDocument(
    aw_models.Document doc,
  ) {
    final raw = doc.data[AppwriteSyncDocumentPayloadKeys.documentJson];
    if (raw is! String) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return MaterialStockSnapshotCodec.fromMap(
        Map<String, dynamic>.from(decoded),
      );
    } on Object catch (error, trace) {
      if (kDebugMode) {
        _logger.log(
          'appwrite_pull_material_stock_json_fail doc=${doc.$id} $error',
        );
        _logger.exception(error, trace);
      }
      return null;
    }
  }

  TaskListEntity? _parseListDocument(aw_models.Document doc) {
    final raw = doc.data[AppwriteSyncDocumentPayloadKeys.documentJson];
    if (raw is! String) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return TaskListEntityCodec.fromMap(Map<String, dynamic>.from(decoded));
    } on Object catch (error, trace) {
      if (kDebugMode) {
        _logger.log('appwrite_pull_list_json_fail doc=${doc.$id} $error');
        _logger.exception(error, trace);
      }
      return null;
    }
  }

  static String _shortUserId(String userId) =>
      userId.length <= 8 ? userId : userId.substring(0, 8);
}

/// Подписка на сессию и сеть: pull с облака и затем слив исходящей очереди.
final class AppwriteCloudInboundSyncCoordinator {
  /// Создаёт координатор.
  AppwriteCloudInboundSyncCoordinator({
    required IAuthGateway authGateway,
    required IConnectivityGateway connectivityGateway,
    required ISyncManager syncManager,
    required AppwriteTaskCloudPuller puller,
    required ILogWriter logger,
  })  : _authGateway = authGateway,
        _connectivityGateway = connectivityGateway,
        _syncManager = syncManager,
        _puller = puller,
        _logger = logger;

  final IAuthGateway _authGateway;
  final IConnectivityGateway _connectivityGateway;
  final ISyncManager _syncManager;
  final AppwriteTaskCloudPuller _puller;
  final ILogWriter _logger;

  bool _pullInFlight = false;
  static String _shortUserId(String userId) =>
      userId.length <= 8 ? userId : userId.substring(0, 8);

  /// Запускает фоновые подписки (не отменяются до завершения процесса).
  void start() {
    _authGateway.authStateChanges.listen(_onAuthChanged);
    _connectivityGateway.onOnline.listen(_onConnectivityOnline);
    unawaited(_pullAndScheduleOutbound());
  }

  Future<void> _onAuthChanged(AppAuthUserEntity? user) async {
    if (kDebugMode) {
      final uid = user?.uid;
      _logger.log(
        'appwrite_inbound_auth_changed user=${uid == null ? 'null' : _shortUserId(uid)} '
        'anonymous=${user?.isAnonymous ?? false}',
      );
    }
    await _pullAndScheduleOutbound();
  }

  Future<void> _onConnectivityOnline(bool online) async {
    if (kDebugMode) {
      _logger.log('appwrite_inbound_connectivity online=$online');
    }
    if (online) {
      await _pullAndScheduleOutbound();
    }
  }

  Future<void> _pullAndScheduleOutbound() async {
    if (_pullInFlight) {
      if (kDebugMode) {
        _logger.log('appwrite_inbound_skip pull_in_flight');
      }
      return;
    }
    final user = _authGateway.currentUser;
    if (user == null || user.isAnonymous) {
      if (kDebugMode) {
        _logger.log(
          'appwrite_inbound_skip user=${user == null ? 'null' : _shortUserId(user.uid)} '
          'anonymous=${user?.isAnonymous ?? false}',
        );
      }
      return;
    }
    final online = await _connectivityGateway.isOnline();
    if (!online) {
      if (kDebugMode) {
        _logger.log('appwrite_inbound_skip offline user=${_shortUserId(user.uid)}');
      }
      return;
    }
    _pullInFlight = true;
    try {
      if (kDebugMode) {
        _logger.log('appwrite_inbound_pull_start user=${_shortUserId(user.uid)}');
      }
      await _puller.pullAllForUser(user.uid);
      await _syncManager.requestSync();
      if (kDebugMode) {
        _logger.log('appwrite_inbound_pull_done user=${_shortUserId(user.uid)}');
      }
    } on AppwriteException catch (error, trace) {
      _logger.log(
        'appwrite_pull_fail code=${error.code} message=${error.message}',
      );
      if (kDebugMode) {
        _logger.exception(error, trace);
      }
    } on Object catch (error, trace) {
      if (kDebugMode) {
        _logger.exception(error, trace);
      }
    } finally {
      _pullInFlight = false;
    }
  }
}
