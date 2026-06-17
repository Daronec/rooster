import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/strings/auth_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Состояние загрузки экрана входа (desktop).
class AuthDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const AuthDesktopLoading({required this.wm, super.key});

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(AuthStrings.screenTitle(context)),
        withBackButton: context.router.root.canPop(),
      ),
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(AuthStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
