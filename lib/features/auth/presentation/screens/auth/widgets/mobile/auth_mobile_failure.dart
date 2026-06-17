import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/strings/auth_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка на экране входа (mobile).
class AuthMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const AuthMobileFailure({
    required this.wm,
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  /// Ошибка.
  final Object error;

  /// Повтор.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(AuthStrings.screenTitle(context)),
        withBackButton: context.router.root.canPop(),
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(AuthStrings.loadBodyError(context)),
            const Height(AppSizes.double8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(AuthStrings.retryLoadBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
