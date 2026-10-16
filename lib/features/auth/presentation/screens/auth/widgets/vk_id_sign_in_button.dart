import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// VK ID sign-in button.
///
/// Stateless button that delegates sign-in to [onTapped] callback.
class VkIdSignInButton extends StatelessWidget {
  /// Creates the VK ID sign-in button.
  ///
  /// [onTapped] is called when the button is pressed.
  const VkIdSignInButton({
    required this.onTapped,
    super.key,
  });

  /// Callback invoked when the button is pressed.
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTapped,
      icon: const Icon(Icons.public, size: 20, color: Colors.white),
      label: Text(
        FlutterI18n.translate(context, 'auth.providerVk'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0077FF),
        foregroundColor: Colors.white,
      ),
    );
  }
}
