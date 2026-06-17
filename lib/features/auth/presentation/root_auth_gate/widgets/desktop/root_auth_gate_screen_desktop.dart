import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_wm.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/desktop/root_auth_gate_desktop_content.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/desktop/root_auth_gate_desktop_failure.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/desktop/root_auth_gate_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Корневой шлюз приложения (desktop).
class RootAuthGateScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const RootAuthGateScreenDesktop({required this.wm, super.key});

  /// Widget model шлюза.
  final RootAuthGateWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          const RootAuthGateDesktopLoading(),
      builder: (context, data) =>
          const RootAuthGateDesktopContent(),
      failureBuilder:
          (context, exception, last) {
        return RootAuthGateDesktopFailure(
          wm: wm,
          error: exception ?? Exception('root_auth_gate'),
        );
      },
    );
  }
}
