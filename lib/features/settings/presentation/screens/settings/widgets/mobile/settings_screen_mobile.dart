import 'package:flutter/material.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_wm.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/mobile/settings_mobile_content.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/mobile/settings_mobile_failure.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/mobile/settings_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран настроек (mobile).
class SettingsScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const SettingsScreenMobile({required this.wm, super.key});

  /// Widget model экрана настроек.
  final SettingsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          SettingsMobileLoading(wm: wm),
      builder: (context, data) =>
          SettingsMobileContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return SettingsMobileFailure(
          wm: wm,
          error: exception ?? Exception('settings'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
