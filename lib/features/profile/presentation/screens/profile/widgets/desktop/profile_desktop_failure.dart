import 'package:flutter/material.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка экрана профиля (desktop).
class ProfileDesktopFailure extends StatelessWidget {
  /// Создаёт виджет.
  const ProfileDesktopFailure({
    required this.wm,
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// Widget model экрана профиля.
  final ProfileScreenWidgetModel wm;

  /// Ошибка.
  final Object error;

  /// Повтор.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(ProfileStrings.screenTitle(context)),
        withBackButton: false,
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(ProfileStrings.loadError(context)),
            const Height(AppSizes.double8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(ProfileStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
