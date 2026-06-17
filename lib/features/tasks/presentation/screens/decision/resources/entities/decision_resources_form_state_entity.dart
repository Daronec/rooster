import 'package:flutter/widgets.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_snapshot_entity.dart';
import 'package:uuid/uuid.dart';

/// Состояние формы «Ресурсы» (presentation): контроллеры ввода и строки склада.
final class DecisionResourcesFormStateEntity extends ChangeNotifier {
  /// Создаёт состояние из загруженного снимка.
  DecisionResourcesFormStateEntity.fromContent(
    DecisionResourcesSnapshotEntity content,
  ) : _initialBudget = content.budget,
      limitController = TextEditingController(
        text: '${content.budget?.amountLimit ?? 0}',
      ),
      _materialRows = content.materials
          .map(DecisionResourcesMaterialRowEntity.fromEntity)
          .toList(growable: true) {
    if (_materialRows.isEmpty) {
      _materialRows.add(DecisionResourcesMaterialRowEntity.empty());
    }
    _bindAllListeners();
  }

  BudgetPeriodEntity? _initialBudget;

  /// Поле ввода «Имеющийся бюджет».
  final TextEditingController limitController;

  final List<DecisionResourcesMaterialRowEntity> _materialRows;

  /// Строки склада.
  List<DecisionResourcesMaterialRowEntity> get materialRows =>
      List<DecisionResourcesMaterialRowEntity>.unmodifiable(_materialRows);

  /// Добавить строку материала.
  void addRow() {
    final row = DecisionResourcesMaterialRowEntity.empty();
    _materialRows.insert(0, row);
    _bindRowListeners(row);
    notifyListeners();
  }

  /// Удалить строку материала.
  void removeRowAt(int index) {
    if (_materialRows.length <= 1) {
      return;
    }
    if (index < 0 || index >= _materialRows.length) {
      return;
    }
    final removedRow = _materialRows.removeAt(index);
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      removedRow.dispose();
    });
  }

  /// Обновить снимок бюджета (year/month/spent), не трогая ввод пользователя.
  void updateInitialBudget(BudgetPeriodEntity? budget) {
    _initialBudget = budget;
  }

  /// Сборка доменной сущности бюджета из текущего ввода.
  BudgetPeriodEntity? tryBuildBudget() {
    final limit = double.tryParse(
      limitController.text.trim().replaceAll(',', '.'),
    );
    if (limit == null) {
      return null;
    }
    final now = DateTime.now();
    final initialBudget = _initialBudget;
    final year = initialBudget?.year ?? now.year;
    final month = initialBudget?.month ?? now.month;
    final clampedMonth = month.clamp(1, 12);
    return BudgetPeriodEntity(
      year: year,
      month: clampedMonth,
      amountLimit: limit < 0 ? 0 : limit,
      amountSpent: (initialBudget?.amountSpent ?? 0).clamp(
        0.0,
        double.infinity,
      ),
    );
  }

  /// Сборка доменных сущностей склада из текущего ввода.
  List<MaterialStockItemEntity> buildMaterials() {
    final materials = <MaterialStockItemEntity>[];
    for (final row in _materialRows) {
      final id = row.id.trim();
      if (id.isEmpty) {
        continue;
      }
      final name = row.nameController.text.trim();
      final quantity =
          double.tryParse(
            row.qtyController.text.trim().replaceAll(',', '.'),
          ) ??
          0;
      materials.add(
        MaterialStockItemEntity(
          id: id,
          name: name,
          quantity: quantity < 0 ? 0 : quantity,
        ),
      );
    }
    return materials;
  }

  /// Сигнатура состояния для дедупликации автосохранения.
  String buildSignature() {
    final budget = tryBuildBudget();
    final signatureBuffer = StringBuffer()
      ..write('limit=')
      ..write(budget?.amountLimit);
    for (final row in _materialRows) {
      signatureBuffer
        ..write('|')
        ..write(row.id.trim())
        ..write(':')
        ..write(row.nameController.text.trim())
        ..write(':')
        ..write(row.qtyController.text.trim());
    }
    return signatureBuffer.toString();
  }

  void _bindAllListeners() {
    limitController.addListener(notifyListeners);
    _materialRows.forEach(_bindRowListeners);
  }

  void _bindRowListeners(DecisionResourcesMaterialRowEntity row) {
    row.nameController.addListener(notifyListeners);
    row.qtyController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    limitController.dispose();
    _materialRows.forEach(_disposeRow);
    super.dispose();
  }

  void _disposeRow(DecisionResourcesMaterialRowEntity row) {
    row.dispose();
  }
}

/// Строка склада в форме «Ресурсы» (presentation).
final class DecisionResourcesMaterialRowEntity {
  /// Пустая строка (новая позиция).
  factory DecisionResourcesMaterialRowEntity.empty() {
    return DecisionResourcesMaterialRowEntity._(
      id: const Uuid().v4(),
      nameController: TextEditingController(),
      qtyController: TextEditingController(text: '0'),
    );
  }

  /// Строка из доменной сущности.
  factory DecisionResourcesMaterialRowEntity.fromEntity(
    MaterialStockItemEntity item,
  ) {
    return DecisionResourcesMaterialRowEntity._(
      id: item.id,
      nameController: TextEditingController(
        text: item.name.trim() == item.id.trim() ? '' : item.name,
      ),
      qtyController: TextEditingController(text: '${item.quantity}'),
    );
  }

  DecisionResourcesMaterialRowEntity._({
    required this.id,
    required this.nameController,
    required this.qtyController,
  });

  bool _isDisposed = false;

  /// Стабильный id позиции.
  final String id;

  /// Поле «Название».
  final TextEditingController nameController;

  /// Поле «Кол-во».
  final TextEditingController qtyController;

  /// Освободить ресурсы.
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    nameController.dispose();
    qtyController.dispose();
  }
}
