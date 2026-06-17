import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_failure.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран входа (mobile).
class AuthScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const AuthScreenMobile({required this.wm, super.key});

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          AuthMobileLoading(wm: wm),
      builder: (context, data) =>
          AuthMobileContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return AuthMobileFailure(
          wm: wm,
          error: exception ?? Exception('auth'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
