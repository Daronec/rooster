import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/data/repositories/noop_budget_repository.dart';
import 'package:rooster/features/tasks/data/repositories/noop_material_stock_repository.dart';

void main() {
  test('NoopBudgetRepository не возвращает период', () async {
    const repository = NoopBudgetRepository();
    expect(await repository.readActivePeriod(), isNull);
  });

  test('NoopMaterialStockRepository возвращает пустой список', () async {
    const repository = NoopMaterialStockRepository();
    expect(await repository.readAllItems(), isEmpty);
  });
}
