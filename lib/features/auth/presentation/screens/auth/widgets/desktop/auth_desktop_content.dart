import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/auth_appwrite_email_section.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Контент экрана входа (desktop).
class AuthDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const AuthDesktopContent({required this.wm, super.key});

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(FlutterI18n.translate(context, 'auth.screenTitle')),
        withBackButton: context.router.root.canPop(),
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              FlutterI18n.translate(context, wm.introTranslationKey),
            ),
            const Height(AppSizes.double16),
            if (wm.supportsEmailPasswordAuth) ...<Widget>[
              AuthAppwriteEmailSection(
                emailFieldController: wm.emailFieldController,
                passwordFieldController: wm.passwordFieldController,
                onSignInPressed: wm.onEmailSignInTap,
                onSignUpPressed: wm.onOpenRegisterScreen,
                onForgotPasswordPressed: wm.onForgotPasswordTap,
              ),
              const Height(AppSizes.double16),
            ],
            if (wm.showGoogleSignInButton) ...<Widget>[
              FilledButton(
                onPressed: wm.onGoogleTap,
                child: Text(
                  FlutterI18n.translate(context, 'auth.providerGoogle'),
                ),
              ),
              const Height(AppSizes.double8),
            ],
            if (wm.showAppleSignInButton) ...<Widget>[
              FilledButton.tonal(
                onPressed: wm.onAppleTap,
                child: Text(
                  FlutterI18n.translate(context, 'auth.providerApple'),
                ),
              ),
              const Height(AppSizes.double8),
            ],
          ],
        ),
      ),
    );
  }
}
