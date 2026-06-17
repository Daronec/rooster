import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:uuid/uuid.dart';

/// Контроллеры одной строки «материал» на форме создания задачи.
final class CreateTaskMaterialRowBinding {
  /// Создаёт привязку с заданными контроллерами.
  CreateTaskMaterialRowBinding({
    required this.id,
    required this.nameController,
    required this.quantityController,
    required this.costController,
    String? stockItemId,
  }) : stockItemIdListenable = ValueNotifier<String?>(stockItemId);

  /// Создаёт пустую строку с новым стабильным [id].
  factory CreateTaskMaterialRowBinding.empty() {
    return CreateTaskMaterialRowBinding(
      id: const Uuid().v4(),
      nameController: TextEditingController(),
      quantityController: TextEditingController(),
      costController: TextEditingController(),
    );
  }

  /// Заполняет контроллеры из доменной строки (режим редактирования).
  factory CreateTaskMaterialRowBinding.fromEntity(
    TaskMaterialRequirementEntity entity,
  ) {
    return CreateTaskMaterialRowBinding(
      id: entity.id,
      nameController: TextEditingController(text: entity.name),
      quantityController: TextEditingController(
        text: _formatDoubleField(entity.requiredQuantity),
      ),
      costController: TextEditingController(
        text: _formatDoubleField(entity.lineCost),
      ),
      stockItemId: entity.stockItemId,
    );
  }

  /// Стабильный идентификатор строки в задаче.
  final String id;

  /// Наименование материала.
  final TextEditingController nameController;

  /// Требуемое количество (текст для поля ввода).
  final TextEditingController quantityController;

  /// Стоимость строки (текст для поля ввода).
  final TextEditingController costController;

  /// Id позиции на складе, если строка пришла из сохранённой задачи.
  final ValueNotifier<String?> stockItemIdListenable;

  /// Текущий выбранный id позиции на складе (или null).
  String? get stockItemId => stockItemIdListenable.value;

  /// Освобождает контроллеры.
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    costController.dispose();
    stockItemIdListenable.dispose();
  }

  static String _formatDoubleField(double value) {
    if (value == 0) {
      return '';
    }
    final text = value.toString();
    if (!text.contains('.')) {
      return text;
    }
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

/// Динамический список строк материалов и уведомление UI об изменениях.
final class CreateTaskMaterialRowsNotifier extends ChangeNotifier {
  final List<CreateTaskMaterialRowBinding> _rows = <CreateTaskMaterialRowBinding>[];

  /// Текущие строки (неизменяемый снимок ссылок).
  List<CreateTaskMaterialRowBinding> get rows => List<CreateTaskMaterialRowBinding>.unmodifiable(_rows);

  /// Заменяет список строк данными из задачи.
  void loadFromRequirements(List<TaskMaterialRequirementEntity> entities) {
    _disposeAllRows();
    _rows.clear();
    for (final entity in entities) {
      _rows.add(CreateTaskMaterialRowBinding.fromEntity(entity));
    }
    notifyListeners();
  }

  /// Добавляет пустую строку в конец списка.
  void addEmptyRow() {
    _rows.add(CreateTaskMaterialRowBinding.empty());
    notifyListeners();
  }

  /// Удаляет строку по [rowId].
  void removeRow(String rowId) {
    final index = _rows.indexWhere((row) => row.id == rowId);
    if (index == -1) {
      return;
    }
    _rows[index].dispose();
    _rows.removeAt(index);
    notifyListeners();
  }

  void _disposeAllRows() {
    for (final row in _rows) {
      row.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAllRows();
    _rows.clear();
    super.dispose();
  }
}
