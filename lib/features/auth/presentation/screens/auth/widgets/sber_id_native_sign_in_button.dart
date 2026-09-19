import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/data/sber_auth_service.dart';

/// Кнопка входа через нативное приложение Сбер ID.
class SberIdNativeSignInButton extends StatefulWidget {
  const SberIdNativeSignInButton({super.key});

  @override
  State<SberIdNativeSignInButton> createState() =>
      _SberIdNativeSignInButtonState();
}

class _SberIdNativeSignInButtonState extends State<SberIdNativeSignInButton> {
  final SberAuthService _authService = SberAuthService();
  bool _isLoading = false;

  Future<void> _handleSignIn(BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final token = await _authService.loginWithSber();

      if (!mounted) return;

      if (token != null) {
        // TODO: Отправить токен на Backend и получить сессию
        // await _authService.exchangeTokenForSession(token);

        if (mounted) {
          // Навигация на главный экран после успешного входа
          // Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // Ошибка или отмена авторизации
        if (mounted) {
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _handleSignIn(context),
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.business, size: 20),
      label: Text(
        FlutterI18n.translate(context, 'auth.providerSber'),
      ),
    );
  }
}
