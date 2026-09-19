import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/data/sber_auth_service.dart';

/// Кнопка входа через нативное приложение Сбер ID.
///
/// Использует stream-based API для обработки асинхронного OAuth-флоу.
class SberIdNativeSignInButton extends StatefulWidget {
  const SberIdNativeSignInButton({super.key});

  @override
  State<SberIdNativeSignInButton> createState() =>
      _SberIdNativeSignInButtonState();
}

class _SberIdNativeSignInButtonState extends State<SberIdNativeSignInButton> {
  final SberAuthService _authService = SberAuthService();
  bool _isLoading = false;
  StreamSubscription<SberAuthResult>? _authSubscription;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Подписываемся на stream результатов авторизации
    _authSubscription = _authService.authStream.listen(
      _handleAuthResult,
      onError: (error, stackTrace) {
        debugPrint('SberIdNativeSignInButton: stream error: $error');
        _finishLogin(context, error: 'auth.streamError');
      },
      onDone: () {
        debugPrint('SberIdNativeSignInButton: stream closed');
      },
    );

    // Запускаем OAuth-флоу
    final started = await _authService.startLogin();

    if (!started && mounted) {
      _finishLogin(context, error: 'auth.sberSignInFailed');
    }
    // Результат придёт через authStream (onSberAuthSuccess / onSberAuthError)
  }

  void _handleAuthResult(SberAuthResult result) {
    if (!mounted) return;

    switch (result) {
      case SberAuthSuccess(:final code):
        // TODO: Отправить code на бэкенд для обмена на токен
        // await _authService.exchangeCodeForToken(code);
        debugPrint('SberIdNativeSignInButton: auth code received: $code');
        Navigator.of(context).pushReplacementNamed('/home');

      case SberAuthFailure(:final error, :final message):
        debugPrint('SberIdNativeSignInButton: auth failed: $error - $message');
        _finishLogin(
          context,
          error: error == 'SBER_ID_CANCELLED'
              ? 'auth.userCancelled'
              : 'auth.sberSignInFailed',
        );
    }
  }

  void _finishLogin(BuildContext context, {required String error}) {
    _authSubscription?.cancel();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FlutterI18n.translate(context, error)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
