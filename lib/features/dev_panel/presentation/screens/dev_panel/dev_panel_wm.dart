import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/sync_status.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_model.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_screen.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// WM dev-панели.
class DevPanelScreenWidgetModel
    extends BaseWidgetModel<DevPanelScreen, DevPanelScreenModel> {
  /// Создаёт WM.
  DevPanelScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required ISyncManager syncManager,
    required IConnectivityGateway connectivity,
    required Listenable syncEngineListenable,
  }) : _syncManager = syncManager,
       _connectivity = connectivity,
       _syncEngineListenable = syncEngineListenable,
       bodyState = UnionStateNotifier<EmptyScreenBody>(EmptyScreenBody.instance),
       super(
         handledFailureLogWriter: logWriter,
       );

  /// Состояние тела экрана.
  final UnionStateNotifier<EmptyScreenBody> bodyState;

  final ISyncManager _syncManager;
  final IConnectivityGateway _connectivity;
  final Listenable _syncEngineListenable;

  /// Строки очереди для UI.
  final ValueNotifier<List<String>> queueLines = ValueNotifier<List<String>>(
    [],
  );

  /// Доступность сети (по connectivity_plus).
  final ValueNotifier<bool?> online = ValueNotifier<bool?>(null);

  /// Пауза исходящего sync.
  final ValueNotifier<bool> outboundPaused = ValueNotifier<bool>(false);

  /// Слушатель статуса sync engine.
  Listenable get syncEngineListenable => _syncEngineListenable;

  /// Вернуть тело экрана в контент после ошибки.
  void retryScreenBody() {
    bodyState.content(EmptyScreenBody.instance);
  }

  /// Статус синка.
  SyncEngineStatus get syncStatus => _syncManager.status;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    unawaited(refresh());
  }

  /// Пауза исходящей синхронизации.
  void setSyncPaused(bool value) {
    outboundPaused.value = value;
    _syncManager.setPaused(value);
  }

  /// Обновить очередь и индикатор сети.
  Future<void> refresh() async {
    final ops = await model.loadQueue();
    queueLines.value = ops
        .map(
          (operation) =>
              '${operation.type.name} ${operation.id} '
              'attempts=${operation.attemptCount} ${operation.lastError ?? ''}',
        )
        .toList();
    online.value = await _connectivity.isOnline();
  }

  @override
  void dispose() {
    queueLines.dispose();
    online.dispose();
    outboundPaused.dispose();
    bodyState.dispose();
    super.dispose();
  }
}
