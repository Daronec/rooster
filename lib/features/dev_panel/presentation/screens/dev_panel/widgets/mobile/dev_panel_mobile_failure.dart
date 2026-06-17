import 'package:flutter/material.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_wm.dart';
import 'package:rooster/features/dev_panel/presentation/strings/dev_panel_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка dev-панели (mobile).
class DevPanelMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const DevPanelMobileFailure({
    required this.wm,
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// Widget model экрана.
  final DevPanelScreenWidgetModel wm;

  /// Ошибка.
  final Object error;

  /// Повтор.
  final VoidCallback onRetry;

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
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(DevPanelStrings.loadError(context)),
            const Height(AppSizes.double8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(DevPanelStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
