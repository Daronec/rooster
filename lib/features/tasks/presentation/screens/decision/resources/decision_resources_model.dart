import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/tasks/domain/decision/task_material_shortage_calculator.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_shortage_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_form_state_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_snapshot_entity.dart';
import 'package:union_state/union_state.dart';

/// Модель экрана «Ресурсы».
final class DecisionResourcesScreenModel extends ElementaryModel {
  /// Создаёт модель.
  DecisionResourcesScreenModel({
    required IBudgetRepository budgetRepository,
    required IMaterialStockRepository materialStockRepository,
    required ITasksRepository tasksRepository,
    ILogWriter? logWriter,
  }) : _budgetRepository = budgetRepository,
       _materialStockRepository = materialStockRepository,
       _tasksRepository = tasksRepository,
       _logWriter = logWriter;

  final IBudgetRepository _budgetRepository;
  final IMaterialStockRepository _materialStockRepository;
  final ITasksRepository _tasksRepository;
  final ILogWriter? _logWriter;

  int _contentRevision = 0;

  /// Состояние формы (контроллеры); создаётся после первой загрузки.
  DecisionResourcesFormStateEntity? _formState;

  /// Текущее состояние формы или null до загрузки.
  DecisionResourcesFormStateEntity? get formState => _formState;

  Timer? _saveDebounce;
  String? _lastSavedSignature;
  bool _isSaving = false;
  List<TaskEntity> _loadedTasks = const <TaskEntity>[];

  /// Увеличивается после каждой успешной загрузки (синхронизация с [DecisionResourcesSnapshotEntity.revision]).
  final ValueNotifier<int> loadGenerationListenable = ValueNotifier<int>(0);

  /// Состояние UI: загрузка / форма / ошибка.
  final UnionStateNotifier<DecisionResourcesSnapshotEntity> bodyState =
      UnionStateNotifier<DecisionResourcesSnapshotEntity>.loading();

  @override
  void init() {
    super.init();
    unawaited(load());
  }

  /// Загрузить бюджет и склад.
  Future<void> load() async {
    bodyState.loading();
    try {
      final budget = await _budgetRepository.readActivePeriod();
      final materials = await _materialStockRepository.readAllItems();
      final tasks = await _tasksRepository.watchTasks().first;
      _loadedTasks = tasks;
      final materialShortages = TaskMaterialShortageCalculator.calculate(
        tasks: tasks,
        stockItems: materials,
      );
      _contentRevision++;
      final content = DecisionResourcesSnapshotEntity(
        materials: materials,
        materialShortages: materialShortages,
        revision: _contentRevision,
        budget: budget,
      );
      final existing = _formState;
      if (existing == null) {
        final newState = DecisionResourcesFormStateEntity.fromContent(content);
        newState.addListener(_onFormStateChanged);
        _formState = newState;
      } else {
        existing.updateInitialBudget(budget);
      }
      bodyState.content(content);
      loadGenerationListenable.value = _contentRevision;
      _logDebug(budget, materials, materialShortages.length);
    } on Object catch (error, stackTrace) {
      bodyState.failure(
        error is Exception ? error : Exception(error.toString()),
        null,
      );
      handleError(error, stackTrace: stackTrace);
    }
  }

  /// Рассчитать дефицит материалов для текущего снимка задач и переданного склада.
  List<TaskMaterialShortageEntity> calculateMaterialShortages(
    List<MaterialStockItemEntity> materials,
  ) {
    return TaskMaterialShortageCalculator.calculate(
      tasks: _loadedTasks,
      stockItems: materials,
    );
  }

  void _logDebug(
    BudgetPeriodEntity? budget,
    List<MaterialStockItemEntity> materials,
    int shortageCount,
  ) {
    if (!kDebugMode) {
      return;
    }
    final writer = _logWriter;
    if (writer == null) {
      return;
    }
    writer.log(
      'decision_resources budget=${budget != null} materials=${materials.length} '
      'shortages=$shortageCount',
    );
  }

  /// Сохранить период и весь список материалов.
  Future<void> saveAll({
    required BudgetPeriodEntity budget,
    required List<MaterialStockItemEntity> materials,
  }) async {
    await _budgetRepository.saveActivePeriod(budget);
    await _materialStockRepository.saveAllItems(materials);
    await load();
  }

  /// Сохранить период и склад без перезагрузки формы (для автосохранения).
  Future<void> saveAllSilently({
    required BudgetPeriodEntity budget,
    required List<MaterialStockItemEntity> materials,
  }) async {
    await _budgetRepository.saveActivePeriod(budget);
    await _materialStockRepository.saveAllItems(materials);
  }

  void _onFormStateChanged() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveNowIfNeeded);
  }

  Future<void> _saveNowIfNeeded() async {
    if (_isSaving) {
      _onFormStateChanged();
      return;
    }
    final state = _formState;
    if (state == null) {
      return;
    }
    final budget = state.tryBuildBudget();
    if (budget == null) {
      return;
    }
    final signature = state.buildSignature();
    if (signature == _lastSavedSignature) {
      return;
    }
    _isSaving = true;
    try {
      await saveAllSilently(
        budget: budget,
        materials: state.buildMaterials(),
      );
      _lastSavedSignature = signature;
    } finally {
      _isSaving = false;
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _formState?.removeListener(_onFormStateChanged);
    _formState?.dispose();
    loadGenerationListenable.dispose();
    bodyState.dispose();
    super.dispose();
  }
}
