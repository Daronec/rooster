import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_wm.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/mobile/root_auth_gate_mobile_content.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/mobile/root_auth_gate_mobile_failure.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/mobile/root_auth_gate_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Корневой шлюз приложения (mobile).
class RootAuthGateScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const RootAuthGateScreenMobile({required this.wm, super.key});

  /// Widget model шлюза.
  final RootAuthGateWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          const RootAuthGateMobileLoading(),
      builder: (context, data) =>
          const RootAuthGateMobileContent(),
      failureBuilder:
          (context, exception, last) {
        return RootAuthGateMobileFailure(
          wm: wm,
          error: exception ?? Exception('root_auth_gate'),
        );
      },
    );
  }
}
