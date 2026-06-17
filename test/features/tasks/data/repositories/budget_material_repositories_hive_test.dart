import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/features/tasks/data/repositories/budget_repository_impl.dart';
import 'package:rooster/features/tasks/data/repositories/material_stock_repository_impl.dart';
import 'package:rooster/features/tasks/data/storage/task_decision_hive_storage_constants.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:uuid/uuid.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('rooster_decision_hive_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen(TaskDecisionHiveStorageConstants.boxName)) {
      await Hive.box<dynamic>(TaskDecisionHiveStorageConstants.boxName).close();
    }
    await Hive.deleteBoxFromDisk(TaskDecisionHiveStorageConstants.boxName);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('BudgetRepositoryImpl сохраняет и читает активный период', () async {
    final box = await Hive.openBox<dynamic>(
      TaskDecisionHiveStorageConstants.boxName,
    );
    final repository = BudgetRepositoryImpl(decisionBox: box);
    const period = BudgetPeriodEntity(
      year: 2026,
      month: 4,
      amountLimit: 500,
      amountSpent: 100,
    );
    await repository.saveActivePeriod(period);
    final read = await repository.readActivePeriod();
    expect(read?.year, 2026);
    expect(read?.month, 4);
    expect(read?.amountLimit, 500);
    expect(read?.amountSpent, 100);
    await repository.clearActivePeriod();
    expect(await repository.readActivePeriod(), isNull);
    await box.close();
  });

  test('MaterialStockRepositoryImpl сохраняет список позиций', () async {
    final box = await Hive.openBox<dynamic>(
      TaskDecisionHiveStorageConstants.boxName,
    );
    final repository = MaterialStockRepositoryImpl(
      decisionBox: box,
      syncQueue: _NoopSyncQueue(),
      syncManagerRef: SyncManagerRef(),
      uuid: const Uuid(),
    );
    final items = [
      const MaterialStockItemEntity(
        id: 'm1',
        name: 'Песок',
        quantity: 3,
        unit: 'м³',
      ),
      const MaterialStockItemEntity(
        id: 'm2',
        name: 'Цемент',
        quantity: 10,
      ),
    ];
    await repository.saveAllItems(items);
    final read = await repository.readAllItems();
    expect(read.length, 2);
    expect(read.first.id, 'm1');
    expect(read.last.quantity, 10);
    await box.close();
  });
}

final class _NoopSyncQueue implements ISyncQueue {
  @override
  Stream<void> get changes => const Stream<void>.empty();

  @override
  Future<void> enqueue(SyncOperation operation) async {}

  @override
  Future<List<SyncOperation>> loadAll() async => const [];

  @override
  Future<void> remove(String operationId) async {}

  @override
  Future<void> update(SyncOperation operation) async {}
}
