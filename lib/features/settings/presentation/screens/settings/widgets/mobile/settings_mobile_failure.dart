import 'package:flutter/material.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_wm.dart';
import 'package:rooster/features/settings/presentation/strings/settings_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка экрана настроек (mobile).
class SettingsMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const SettingsMobileFailure({
    required this.wm,
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// Widget model экрана настроек.
  final SettingsScreenWidgetModel wm;

  /// Ошибка.
  final Object error;

  /// Повтор.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(SettingsStrings.screenTitle(context)),
        withBackButton: false,
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(SettingsStrings.loadError(context)),
            const Height(AppSizes.double8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(SettingsStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
