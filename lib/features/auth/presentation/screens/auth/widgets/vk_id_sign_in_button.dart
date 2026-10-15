import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/features/app/di/app_scope.dart';

/// VK ID sign-in button with loading state support.
///
/// Uses [IVkIdGateway.signInWithVkId()] to launch OAuth flow.
class VkIdSignInButton extends StatefulWidget {
  const VkIdSignInButton({
    required this.logWriter,
    super.key,
  });

  /// Logger for error tracking.
  final ILogWriter logWriter;

  @override
  State<VkIdSignInButton> createState() => _VkIdSignInButtonState();
}

class _VkIdSignInButtonState extends State<VkIdSignInButton> {
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
          : const Icon(Icons.public, size: 20, color: Colors.white),
      label: Text(
        FlutterI18n.translate(context, 'auth.providerVk'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0077FF),
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    if (_isLoading || !context.mounted) return;
    setState(() => _isLoading = true);
    try {
      final vkIdGateway = context.read<IAppScope>().vkIdGateway;
      await vkIdGateway.signInWithVkId();
    } on Exception catch (e) {
      widget.logWriter.log('vk_sign_in_failed: $e');
      if (context.mounted) {
        SnackQueueProvider.of(context).addSnack(
          FlutterI18n.translate(context, 'auth.vkSignInFailed'),
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
