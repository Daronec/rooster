import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_member_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';
import 'package:rooster/features/tasks/domain/entities/task_participant_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_creation_input_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_local_image_gateway.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/services/task_entity_from_creation_input.dart';
import 'package:rooster/features/tasks/domain/use_cases/complete_task_and_consume_stock_materials_use_case.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/util/extensions/value_notifier_x.dart';
import 'package:union_state/union_state.dart';
import 'package:uuid/uuid.dart';

/// Модель экрана создания задачи: загрузка списков и сохранение.
final class CreateTaskScreenModel extends ElementaryModel {
  /// Создаёт модель.
  CreateTaskScreenModel({
    required ITasksRepository tasksRepository,
    required ITaskListsRepository taskListsRepository,
    required IMaterialStockRepository materialStockRepository,
    required CompleteTaskAndConsumeStockMaterialsUseCase
    completeTaskAndConsumeStockMaterialsUseCase,
    required ITaskLocalImageGateway taskLocalImageGateway,
    required IAuthGateway authGateway,
    required AuthBackendStrategy authBackendStrategy,
    required ITeamsGateway teamsGateway,
    required Uuid uuid,
    this.editingTaskId,
    this.initialTitle,
    this.initialDescription,
    this.initialDependentTaskIds = const [],
  }) : _tasksRepository = tasksRepository,
       _taskListsRepository = taskListsRepository,
       _materialStockRepository = materialStockRepository,
       _completeTaskAndConsumeStockMaterialsUseCase =
           completeTaskAndConsumeStockMaterialsUseCase,
       _taskLocalImageGateway = taskLocalImageGateway,
       _authGateway = authGateway,
       _authBackendStrategy = authBackendStrategy,
       _teamsGateway = teamsGateway,
       _uuid = uuid;

  /// Id задачи для режима редактирования; null — создание новой.
  final String? editingTaskId;

  /// Начальный заголовок для режима создания.
  final String? initialTitle;

  /// Начальное описание для режима создания.
  final String? initialDescription;

  /// Задачи, которые должны зависеть от новой задачи после её создания.
  final List<String> initialDependentTaskIds;

  final ITasksRepository _tasksRepository;
  final ITaskListsRepository _taskListsRepository;
  final IMaterialStockRepository _materialStockRepository;
  final CompleteTaskAndConsumeStockMaterialsUseCase
  _completeTaskAndConsumeStockMaterialsUseCase;
  final ITaskLocalImageGateway _taskLocalImageGateway;
  final IAuthGateway _authGateway;
  final AuthBackendStrategy _authBackendStrategy;
  final ITeamsGateway _teamsGateway;
  final Uuid _uuid;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  /// Текущий пользователь, если есть активная сессия.
  AppAuthUserEntity? get currentUser => _authGateway.currentUser;

  /// Состояние загрузки списков задач ([UnionStateListenable] с элементами [TaskListEntity]).
  final ValueNotifier<UnionState<List<TaskListEntity>>> listsState =
      ValueNotifier<UnionState<List<TaskListEntity>>>(
        const UnionStateLoading<List<TaskListEntity>>(),
      );

  /// Подзадачи редактируемой задачи (если [editingTaskId] задан).
  final ValueNotifier<List<TaskEntity>> subtasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  /// Все задачи для выбора родителя.
  final ValueNotifier<List<TaskEntity>> allTasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  /// Позиции склада материалов для выбора в форме.
  final ValueNotifier<List<MaterialStockItemEntity>>
  materialStockItemsListenable = ValueNotifier<List<MaterialStockItemEntity>>(
    <MaterialStockItemEntity>[],
  );

  /// Индикатор загрузки участников из команд Appwrite.
  final ValueNotifier<bool> participantsLoadingListenable = ValueNotifier<bool>(
    false,
  );

  /// Участники (плоский список по всем командам пользователя).
  final ValueNotifier<List<TaskParticipantEntity>> participantsListenable =
      ValueNotifier<List<TaskParticipantEntity>>(<TaskParticipantEntity>[]);

  /// Состояние сохранения задачи.
  final PageStateNotifier saveState = PageStateNotifier();

  @override
  void init() {
    super.init();
    _tasksSubscription?.cancel();
    _tasksSubscription = _tasksRepository.watchTasks().listen(
      (tasks) {
        allTasksListenable.value = tasks;
        final parentId = editingTaskId;
        if (parentId == null || parentId.isEmpty) {
          subtasksListenable.value = const <TaskEntity>[];
          return;
        }
        final subtasks =
            tasks
                .where((task) => task.parentTaskId == parentId)
                .toList(growable: false)
              ..sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
        subtasksListenable.value = subtasks;
      },
      onError: (Object error, StackTrace stackTrace) {
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  /// Загрузить списки для выпадающего списка.
  Future<void> loadLists() async {
    listsState.emit(const UnionStateLoading<List<TaskListEntity>>());
    try {
      final lists = await _taskListsRepository.watchLists().first;
      listsState.emit(UnionStateContent<List<TaskListEntity>>(lists));
    } on Exception catch (exception) {
      listsState.emit(UnionStateFailure<List<TaskListEntity>>(exception));
    } on Object catch (error) {
      listsState.emit(
        UnionStateFailure<List<TaskListEntity>>(
          Exception(error.toString()),
        ),
      );
    }
  }

  /// Загрузить задачу для редактирования.
  Future<TaskEntity?> loadEditingTask() async {
    final id = editingTaskId;
    if (kDebugMode) {
      debugPrint('create_task_load_editing_task editingTaskId=$id');
    }
    if (id == null) {
      return null;
    }
    return _tasksRepository.loadTask(id);
  }

  /// Загрузить склад материалов для подсказок/выбора.
  Future<void> loadMaterialStock() async {
    try {
      final items = await _materialStockRepository.readAllItems();
      materialStockItemsListenable.value = items;
    } on Object catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace);
    }
  }

  /// Загрузить участников из команд Appwrite (если поддерживается стратегией и есть пользователь).
  Future<void> loadParticipantsFromTeams() async {
    if (_authBackendStrategy != AuthBackendStrategy.appwrite) {
      participantsListenable.value = const <TaskParticipantEntity>[];
      participantsLoadingListenable.value = false;
      return;
    }
    final user = _authGateway.currentUser;
    if (user == null || user.isAnonymous) {
      participantsListenable.value = const <TaskParticipantEntity>[];
      participantsLoadingListenable.value = false;
      return;
    }
    participantsLoadingListenable.value = true;
    try {
      final teams = await _teamsGateway.loadTeamsWithMembers(user.uid);
      participantsListenable.value = _flattenParticipants(teams);
    } on Object catch (error, stackTrace) {
      participantsListenable.value = const <TaskParticipantEntity>[];
      handleError(error, stackTrace: stackTrace);
    } finally {
      participantsLoadingListenable.value = false;
    }
  }

  static List<TaskParticipantEntity> _flattenParticipants(
    List<ProfileTeamCardEntity> teams,
  ) {
    final bySelectionId = <String, TaskParticipantEntity>{};
    for (final team in teams) {
      for (final member in team.members) {
        final participant = _participantFromMember(team.teamId, member);
        final key = '${participant.teamId}:${participant.userId}';
        bySelectionId.putIfAbsent(key, () => participant);
      }
    }
    final out = bySelectionId.values.toList(growable: false)
      ..sort((a, b) => a.label.compareTo(b.label));
    return List<TaskParticipantEntity>.unmodifiable(out);
  }

  static TaskParticipantEntity _participantFromMember(
    String teamId,
    ProfileTeamMemberEntity member,
  ) {
    final name = member.displayName.trim();
    final email = member.email.trim();
    final label = name.isNotEmpty
        ? name
        : email.isNotEmpty
        ? email
        : member.userId;
    return TaskParticipantEntity(
      teamId: teamId,
      userId: member.userId,
      label: label,
    );
  }

  /// Загрузить задачу по id (например родителя для подзадачи).
  Future<TaskEntity?> loadTask(String taskId) =>
      _tasksRepository.loadTask(taskId);

  /// Сохранить задачу локально и поставить в очередь синхронизации.
  Future<TaskEntity> saveTask(TaskCreationInputEntity input) async {
    saveState.loading();
    try {
      final editId = editingTaskId;
      if (editId != null) {
        final existing = await _tasksRepository.loadTask(editId);
        if (existing == null) {
          throw StateError('task_not_found');
        }
        final images = await _persistImages(
          input.imageAttachments,
          taskId: editId,
        );
        final resolved = input.copyWith(
          imageAttachments: images,
        );
        final merged = TaskEntityFromCreationInput.mergeExisting(
          existing: existing,
          input: resolved,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await _tasksRepository.saveTask(merged);
        saveState.content();
        return merged;
      }

      final id = _uuid.v4();
      final images = await _persistImages(input.imageAttachments, taskId: id);
      final resolved = input.copyWith(
        imageAttachments: images,
      );
      final task = TaskEntityFromCreationInput.build(
        input: resolved,
        id: id,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
      await _tasksRepository.saveTask(task);
      await _linkDependentTasksToNewTask(task.id);
      saveState.content();
      return task;
    } on Object catch (error) {
      saveState.failure(exception: error);
      rethrow;
    }
  }

  Future<void> _linkDependentTasksToNewTask(String newTaskId) async {
    final normalizedIds = _normalizeTaskIds(initialDependentTaskIds);
    if (normalizedIds.isEmpty) {
      return;
    }
    for (final dependentTaskId in normalizedIds) {
      if (dependentTaskId == newTaskId) {
        continue;
      }
      final dependentTask = await _tasksRepository.loadTask(dependentTaskId);
      if (dependentTask == null ||
          dependentTask.dependencyTaskIds.contains(newTaskId)) {
        continue;
      }
      await _tasksRepository.saveTask(
        dependentTask.copyWith(
          dependencyTaskIds: <String>[
            ...dependentTask.dependencyTaskIds,
            newTaskId,
          ],
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  List<String> _normalizeTaskIds(Iterable<String> ids) {
    final seen = <String>{};
    final result = <String>[];
    for (final rawId in ids) {
      final id = rawId.trim();
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      result.add(id);
    }
    return List<String>.unmodifiable(result);
  }

  Future<List<TaskImageAttachmentEntity>> _persistImages(
    List<TaskImageAttachmentEntity> attachments, {
    required String taskId,
  }) async {
    if (attachments.isEmpty) {
      return const <TaskImageAttachmentEntity>[];
    }
    final out = <TaskImageAttachmentEntity>[];
    for (final item in attachments) {
      final path = item.localPath.trim();
      if (path.isEmpty) {
        continue;
      }
      final persisted = await _taskLocalImageGateway.persistPickerFile(
        path,
        taskId: taskId,
      );
      out.add(item.copyWith(localPath: persisted));
    }
    return List<TaskImageAttachmentEntity>.unmodifiable(out);
  }

  /// Сохранить существующую задачу (например подзадачу) напрямую.
  Future<void> saveExistingTask(TaskEntity task) =>
      _tasksRepository.saveTask(task);

  /// Переключить выполнение существующей задачи (например подзадачи) с учётом склада.
  Future<void> setTaskCompleted({
    required TaskEntity task,
    required bool completed,
  }) {
    return _completeTaskAndConsumeStockMaterialsUseCase.execute(
      task: task,
      completed: completed,
    );
  }

  /// Удалить задачу (например подзадачу) напрямую.
  Future<void> deleteTask(String taskId) => _tasksRepository.deleteTask(taskId);

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    listsState.dispose();
    subtasksListenable.dispose();
    allTasksListenable.dispose();
    materialStockItemsListenable.dispose();
    participantsLoadingListenable.dispose();
    participantsListenable.dispose();
    super.dispose();
  }
}
