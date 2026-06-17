import 'package:flutter/material.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_wm.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/desktop/dev_panel_desktop_content.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/desktop/dev_panel_desktop_failure.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/desktop/dev_panel_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран dev-панели (desktop).
class DevPanelScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const DevPanelScreenDesktop({required this.wm, super.key});

  /// Widget model экрана.
  final DevPanelScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          DevPanelDesktopLoading(wm: wm),
      builder: (context, data) =>
          DevPanelDesktopContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return DevPanelDesktopFailure(
          wm: wm,
          error: exception ?? Exception('dev_panel'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
