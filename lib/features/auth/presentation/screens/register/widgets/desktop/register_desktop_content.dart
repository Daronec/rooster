import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_wm.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Форма регистрации (desktop).
class RegisterDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const RegisterDesktopContent({required this.wm, super.key});

  /// Widget model.
  final RegisterScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(
          FlutterI18n.translate(context, 'auth.registerScreenTitle'),
        ),
        withBackButton: context.router.root.canPop(),
      ),
      body: SingleChildScrollView(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: wm.emailFieldController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'auth.emailFieldLabel',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'auth.emailFieldHint',
                ),
              ),
            ),
            const Height(AppSizes.double12),
            AppTextField(
              controller: wm.passwordFieldController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'auth.passwordLabel',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'auth.passwordHint',
                ),
              ),
            ),
            const Height(AppSizes.double12),
            AppTextField(
              controller: wm.passwordConfirmFieldController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'auth.passwordConfirmLabel',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'auth.passwordConfirmHint',
                ),
              ),
            ),
            const Height(AppSizes.double12),
            AppTextField(
              controller: wm.nameFieldController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'auth.registerNameLabel',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'auth.registerNameHint',
                ),
              ),
            ),
            const Height(AppSizes.double12),
            AppTextField(
              controller: wm.phoneFieldController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'auth.registerPhoneLabel',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'auth.registerPhoneHint',
                ),
              ),
            ),
            const Height(AppSizes.double24),
            FilledButton(
              onPressed: () {
                unawaited(wm.onSubmitRegister());
              },
              child: Text(
                FlutterI18n.translate(
                  context,
                  'auth.registerSubmitButton',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
