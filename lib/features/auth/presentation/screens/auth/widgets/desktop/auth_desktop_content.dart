import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/vk_id_sign_in_button.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/yandex_id_sign_in_button.dart';
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
            const Height(AppSizes.double32),
            // Кнопка VK ID
            VkIdSignInButton(onTapped: wm.onVkIdTap),
            const Height(AppSizes.double8),
            // Кнопка Yandex ID
            YandexIdSignInButton(onTapped: wm.onYandexIdTap),
            const Height(AppSizes.double8),
          ],
        ),
      ),
    );
  }
}
