import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_missing_material_entity.dart';

/// Детали блокировки для UI и локализации (плейсхолдеры вместо конкатенации строк в WM).
final class TaskFeasibilityBlockDetailEntity {
  /// Создаёт описание блокировки.
  const TaskFeasibilityBlockDetailEntity({
    required this.status,
    this.moneyDeficit = 0,
    this.missingMaterialIds = const [],
    this.missingMaterials = const [],
    this.blockingTaskIds = const [],
    this.blockingTaskTitles = const [],
  });

  /// Тип блокировки.
  final TaskFeasibilityStatusEntity status;

  /// Нехватка средств (положительное число), смысл только при [status] == blockedMoney.
  final double moneyDeficit;

  /// Id позиций склада, которых не хватает.
  final List<String> missingMaterialIds;

  /// Недостающие материалы для UI (название + сколько не хватает).
  final List<TaskMissingMaterialEntity> missingMaterials;

  /// Id задач-предшественников, из‑за которых стоит блокировка.
  final List<String> blockingTaskIds;

  /// Заголовки задач-предшественников для отображения причины блокировки.
  final List<String> blockingTaskTitles;
}
