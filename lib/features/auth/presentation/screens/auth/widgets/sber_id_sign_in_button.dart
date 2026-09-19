import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';

/// Кнопка входа через Sber ID.
///
/// Использует [IAuthGateway.signInWithSberId()] который реализует OAuth2
/// через Appwrite (cloud.ru). Appwrite сам обменивает код на сессию.
class SberIdSignInButton extends StatelessWidget {
  const SberIdSignInButton({required this.gateway, super.key});

  /// Шлюз авторизации (Appwrite или Offline).
  final IAuthGateway gateway;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleSignIn(context),
      icon: const Icon(Icons.business, size: 20),
      label: Text(
        FlutterI18n.translate(context, 'auth.providerSber'),
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await gateway.signInWithSberId();
      // После успешного входа навигация обрабатывается AuthFlow
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FlutterI18n.translate(context, 'auth.sberSignInFailed')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
