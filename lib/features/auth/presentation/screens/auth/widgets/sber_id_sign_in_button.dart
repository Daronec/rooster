import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/features/app/di/app_scope.dart';

/// Кнопка входа через Sber ID с поддержкой состояния загрузки.
///
/// Использует [ISberIdGateway.signInWithSberId()] для запуска OAuth-флоу.
class SberIdSignInButton extends StatefulWidget {
  /// Создаёт кнопку.
  const SberIdSignInButton({
    required this.logWriter,
    super.key,
  });

  /// Логгер для записи ошибок.
  final ILogWriter logWriter;

  @override
  State<SberIdSignInButton> createState() => _SberIdSignInButtonState();
}

class _SberIdSignInButtonState extends State<SberIdSignInButton> {
  bool _isLoading = false;

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

  Future<void> _handleSignIn(BuildContext context) async {
    if (_isLoading || !context.mounted) return;

    setState(() => _isLoading = true);

    try {
      final sberIdGateway = context.read<IAppScope>().sberIdGateway;
      await sberIdGateway.signInWithSberId();
      // После успешного входа навигация обрабатывается AuthFlow через authStateChanges
    } on Exception catch (e) {
      widget.logWriter.log('sber_sign_in_failed: $e');
      if (context.mounted) {
        SnackQueueProvider.of(context).addSnack(
          FlutterI18n.translate(context, 'auth.sberSignInFailed'),
          messageType: SnackMessageType.error,
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
