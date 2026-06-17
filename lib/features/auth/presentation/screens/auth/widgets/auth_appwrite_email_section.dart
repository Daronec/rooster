import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Поля email, пароль и кнопки входа/регистрации (Appwrite email/password).
class AuthAppwriteEmailSection extends StatelessWidget {
  /// Создаёт блок формы.
  const AuthAppwriteEmailSection({
    required this.emailFieldController,
    required this.passwordFieldController,
    required this.onSignInPressed,
    required this.onSignUpPressed,
    required this.onForgotPasswordPressed,
    super.key,
  });

  /// Контроллер поля email.
  final TextEditingController emailFieldController;

  /// Контроллер поля пароля.
  final TextEditingController passwordFieldController;

  /// Нажатие «Войти».
  final VoidCallback onSignInPressed;

  /// Открыть экран регистрации (полная форма).
  final VoidCallback onSignUpPressed;

  /// Нажатие «Забыли пароль».
  final VoidCallback onForgotPasswordPressed;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppTextField(
            controller: emailFieldController,
            keyboardType: TextInputType.emailAddress,
            autoFillHints: const <String>[AutofillHints.email],
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
            controller: passwordFieldController,
            obscureText: true,
            autoFillHints: const <String>[AutofillHints.password],
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
          const Height(AppSizes.double16),
          FilledButton(
            onPressed: onSignInPressed,
            child: Text(
              FlutterI18n.translate(context, 'auth.emailSignInButton'),
            ),
          ),
          const Height(AppSizes.double8),
          FilledButton.tonal(
            onPressed: onSignUpPressed,
            child: Text(
              FlutterI18n.translate(context, 'auth.emailSignUpButton'),
            ),
          ),
          const Height(AppSizes.double8),
          TextButton(
            onPressed: onForgotPasswordPressed,
            child: Text(
              FlutterI18n.translate(context, 'auth.forgotPassword'),
            ),
          ),
        ],
      ),
    );
  }
}
