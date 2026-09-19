import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/uikit/fields/app_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Секция входа/регистрации по email и паролю (универсальная, без привязки к провайдеру).
class AuthEmailPasswordSection extends StatelessWidget {
  /// Создаёт секцию.
  const AuthEmailPasswordSection({
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

  /// Обработчик нажатия на кнопку входа.
  final VoidCallback onSignInPressed;

  /// Обработчик нажатия на кнопку регистрации.
  final VoidCallback onSignUpPressed;

  /// Обработчик нажатия на ссылку "Забыли пароль?".
  final VoidCallback onForgotPasswordPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppField(
          controller: emailFieldController,
          labelText: FlutterI18n.translate(context, 'auth.emailLabel'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const Height(AppSizes.double16),
        AppField(
          controller: passwordFieldController,
          labelText: FlutterI18n.translate(context, 'auth.passwordLabel'),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSignInPressed(),
        ),
        const Height(AppSizes.double16),
        FilledButton(
          onPressed: onSignInPressed,
          child: Text(FlutterI18n.translate(context, 'auth.signIn')),
        ),
        const Height(AppSizes.double8),
        OutlinedButton(
          onPressed: onSignUpPressed,
          child: Text(FlutterI18n.translate(context, 'auth.signUp')),
        ),
        const Height(AppSizes.double8),
        TextButton(
          onPressed: onForgotPasswordPressed,
          child: Text(
            FlutterI18n.translate(context, 'auth.forgotPassword'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
