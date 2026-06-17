import 'package:flutter/material.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/desktop/profile_desktop_content.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/desktop/profile_desktop_failure.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/desktop/profile_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран профиля (desktop).
class ProfileScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const ProfileScreenDesktop({required this.wm, super.key});

  /// Widget model экрана профиля.
  final ProfileScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) => ProfileDesktopLoading(wm: wm),
      builder: (context, data) => ProfileDesktopContent(wm: wm),
      failureBuilder: (context, exception, last) {
        return ProfileDesktopFailure(
          wm: wm,
          error: exception ?? Exception('profile'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
