import 'package:flutter/material.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_wm.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/desktop/settings_desktop_content.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/desktop/settings_desktop_failure.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/desktop/settings_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран настроек (desktop).
class SettingsScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const SettingsScreenDesktop({required this.wm, super.key});

  /// Widget model экрана настроек.
  final SettingsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          SettingsDesktopLoading(wm: wm),
      builder: (context, data) =>
          SettingsDesktopContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return SettingsDesktopFailure(
          wm: wm,
          error: exception ?? Exception('settings'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
