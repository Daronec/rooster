import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/features/app/di/app_scope.dart';

/// Yandex ID sign-in button with loading state support.
///
/// Uses [IYandexIdGateway.signInWithYandexId()] to launch OAuth flow.
class YandexIdSignInButton extends StatefulWidget {
  const YandexIdSignInButton({
    required this.logWriter,
    super.key,
  });

  /// Logger for error tracking.
  final ILogWriter logWriter;

  @override
  State<YandexIdSignInButton> createState() => _YandexIdSignInButtonState();
}

class _YandexIdSignInButtonState extends State<YandexIdSignInButton> {
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
          : const Icon(Icons.language, size: 20),
      label: Text(
        FlutterI18n.translate(context, 'auth.providerYandex'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFBE00),
        foregroundColor: Colors.black,
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    if (_isLoading || !context.mounted) return;
    setState(() => _isLoading = true);
    try {
      final yandexIdGateway = context.read<IAppScope>().yandexIdGateway;
      await yandexIdGateway.signInWithYandexId();
    } on Exception catch (e) {
      widget.logWriter.log('yandex_sign_in_failed: $e');
      if (context.mounted) {
        SnackQueueProvider.of(context).addSnack(
          FlutterI18n.translate(context, 'auth.yandexSignInFailed'),
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
