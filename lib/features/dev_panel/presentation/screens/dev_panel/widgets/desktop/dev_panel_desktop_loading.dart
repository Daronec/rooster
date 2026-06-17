import 'package:flutter/material.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_wm.dart';
import 'package:rooster/features/dev_panel/presentation/strings/dev_panel_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Состояние загрузки dev-панели (desktop).
class DevPanelDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const DevPanelDesktopLoading({required this.wm, super.key});

  /// Widget model экрана.
  final DevPanelScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(DevPanelStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
