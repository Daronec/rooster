import 'package:flutter/material.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_wm.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/mobile/dev_panel_mobile_content.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/mobile/dev_panel_mobile_failure.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/mobile/dev_panel_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран dev-панели (mobile).
class DevPanelScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const DevPanelScreenMobile({required this.wm, super.key});

  /// Widget model экрана.
  final DevPanelScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          DevPanelMobileLoading(wm: wm),
      builder: (context, data) =>
          DevPanelMobileContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return DevPanelMobileFailure(
          wm: wm,
          error: exception ?? Exception('dev_panel'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
