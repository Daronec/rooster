import 'package:flutter/material.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_screen_body.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_screen_edit_name_app_bar_action.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Контент экрана профиля (mobile).
class ProfileMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const ProfileMobileContent({required this.wm, super.key});

  /// Widget model экрана профиля.
  final ProfileScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(ProfileStrings.screenTitle(context)),
        withBackButton: false,
        actions: <Widget>[
          ProfileScreenEditNameAppBarAction(wm: wm),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: wm.onOpenSettings,
          ),
        ],
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: ProfileScreenBody(wm: wm),
      ),
    );
  }
}
