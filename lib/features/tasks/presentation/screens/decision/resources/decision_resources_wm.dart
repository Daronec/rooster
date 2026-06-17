import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_form_state_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_shortage_entity.dart';
import 'package:rooster/util/app_typedefs.dart';

/// WM экрана «Ресурсы».
final class DecisionResourcesScreenWidgetModel
    extends
        BaseWidgetModel<DecisionResourcesScreen, DecisionResourcesScreenModel> {
  /// Создаёт WM.
  DecisionResourcesScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(handledFailureLogWriter: logWriter);

  /// Состояние загрузки / контент / ошибка для формы.
  UnionStateListenable<DecisionResourcesSnapshotEntity> get bodyState =>
      model.bodyState;

  /// Поколение успешной загрузки (синхронизация с [DecisionResourcesSnapshotEntity.revision]).
  ValueNotifier<int> get loadGenerationListenable =>
      model.loadGenerationListenable;

  /// Повторить загрузку после сбоя.
  Future<void> onRetry() => model.load();

  /// Состояние формы (контроллеры).
  DecisionResourcesFormStateEntity? get formState => model.formState;

  /// Рассчитать дефицит материалов для переданного списка ресурсов.
  List<TaskMaterialShortageEntity> calculateMaterialShortages(
    List<MaterialStockItemEntity> materials,
  ) {
    return model.calculateMaterialShortages(materials);
  }

  /// Добавить строку материала в UI.
  void onAddMaterialRow() {
    FocusManager.instance.primaryFocus?.unfocus();
    final state = formState;
    if (state == null) {
      return;
    }
    state.addRow();
  }

  /// Удалить строку материала в UI.
  void onRemoveMaterialRowAt(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    final state = formState;
    if (state == null) {
      return;
    }
    state.removeRowAt(index);
  }
}
