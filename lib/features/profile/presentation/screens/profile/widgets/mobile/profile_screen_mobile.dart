import 'package:flutter/material.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/mobile/profile_mobile_content.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/mobile/profile_mobile_failure.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/mobile/profile_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран профиля (mobile).
class ProfileScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const ProfileScreenMobile({required this.wm, super.key});

  /// Widget model экрана профиля.
  final ProfileScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) => ProfileMobileLoading(wm: wm),
      builder: (context, data) => ProfileMobileContent(wm: wm),
      failureBuilder: (context, exception, last) {
        return ProfileMobileFailure(
          wm: wm,
          error: exception ?? Exception('profile'),
          onRetry: wm.retryScreenBody,
        );
      },
    );
  }
}
