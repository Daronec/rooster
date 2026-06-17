import 'package:flutter/material.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Состояние загрузки экрана профиля (desktop).
class ProfileDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const ProfileDesktopLoading({required this.wm, super.key});

  /// Widget model экрана профиля.
  final ProfileScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(ProfileStrings.screenTitle(context)),
        withBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(ProfileStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
