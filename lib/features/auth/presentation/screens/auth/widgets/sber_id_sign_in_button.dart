import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';

/// Кнопка входа через Sber ID.
class SberIdSignInButton extends StatelessWidget {
  /// Создаёт кнопку.
  const SberIdSignInButton({
    required this.gateway,
    this.onSignInSuccess,
    this.onSignInError,
    super.key,
  });

  /// Gateway для входа через Sber ID.
  final ISberIdGateway gateway;

  /// Callback при успешном входе.
  final VoidCallback? onSignInSuccess;

  /// Callback при ошибке входа.
  final void Function(Object error)? onSignInError;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: gateway.isSberIdAvailable ? () => _handleSignIn(context) : null,
      icon: const Icon(Icons.business),
      label: Text(
        FlutterI18n.translate(context, 'auth.providerSber'),
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final user = await gateway.signInWithSberId();
      if (user == null) {
        // Ошибка или отмена авторизации
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                FlutterI18n.translate(context, 'auth.sberSignInFailed'),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
      // Успешный вход
      onSignInSuccess?.call();
    } on Object catch (error) {
      onSignInError?.call(error);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FlutterI18n.translate(context, 'auth.sberSignInFailed'),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
