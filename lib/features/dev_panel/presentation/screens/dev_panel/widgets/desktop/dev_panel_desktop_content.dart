import 'package:flutter/material.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_wm.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Контент dev-панели (desktop).
class DevPanelDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const DevPanelDesktopContent({required this.wm, super.key});

  /// Widget model экрана.
  final DevPanelScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable?>[
        wm.syncEngineListenable,
        wm.queueLines,
        wm.online,
        wm.outboundPaused,
      ]),
      builder: (context, _) {
        return AppScaffold(
          appBar: DefaultAppBar(
            title: const Text('Dev / Sync'),
            actions: <Widget>[
              IconButton(
                onPressed: wm.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: AppSizes.edgeInsetsAll16,
            children: <Widget>[
              Text('Статус: ${wm.syncStatus}'),
              Text('Сеть (индикатор): ${wm.online.value ?? '…'}'),
              ValueListenableBuilder<bool>(
                valueListenable: wm.outboundPaused,
                builder: (context, paused, __) {
                  return SwitchListTile(
                    title: const Text('Пауза исходящего sync'),
                    subtitle: const Text('Очередь копится локально'),
                    value: paused,
                    onChanged: wm.setSyncPaused,
                  );
                },
              ),
              const Height(AppSizes.double16),
              const Text(
                'Очередь:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...wm.queueLines.value.map(Text.new),
            ],
          ),
        );
      },
    );
  }
}
