import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/desktop/auth_desktop_content.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/desktop/auth_desktop_failure.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/desktop/auth_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран входа (desktop).
class AuthScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const AuthScreenDesktop({required this.wm, super.key});

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          AuthDesktopLoading(wm: wm),
      builder: (context, data) =>
          AuthDesktopContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return AuthDesktopFailure(
          wm: wm,
          error: exception ?? Exception('auth'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
