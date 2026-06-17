import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Модель списков задач.
final class TaskListsScreenModel extends ElementaryModel {
  /// Создаёт модель.
  TaskListsScreenModel({required ITaskListsRepository repository})
    : _repository = repository;

  final ITaskListsRepository _repository;

  StreamSubscription<List<TaskListEntity>>? _listsSubscription;

  /// Актуальные списки для UI.
  final ValueNotifier<List<TaskListEntity>> listsListenable =
      ValueNotifier<List<TaskListEntity>>(<TaskListEntity>[]);

  /// Состояние тела экрана.
  final UnionStateNotifier<EmptyScreenBody> bodyState =
      UnionStateNotifier<EmptyScreenBody>.loading();

  @override
  void init() {
    super.init();
    _subscribeLists();
  }

  void _subscribeLists() {
    _listsSubscription?.cancel();
    bodyState.loading();
    _listsSubscription = _repository.watchLists().listen(
      (lists) {
        listsListenable.value = lists;
        bodyState.content(EmptyScreenBody.instance);
      },
      onError: (Object error, StackTrace stackTrace) {
        bodyState.failure(
          error is Exception ? error : Exception(error.toString()),
          null,
        );
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  /// Повторная подписка после ошибки потока.
  void retryListsStream() {
    _subscribeLists();
  }

  /// Удалить список локально и поставить операцию синхронизации.
  Future<void> deleteList(String listId) => _repository.deleteList(listId);

  @override
  void dispose() {
    _listsSubscription?.cancel();
    _listsSubscription = null;
    listsListenable.dispose();
    bodyState.dispose();
    super.dispose();
  }
}
