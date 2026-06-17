import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/desktop/root_auth_gate_desktop_loading.dart';

/// Контент корневого шлюза (desktop).
class RootAuthGateDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const RootAuthGateDesktopContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const RootAuthGateDesktopLoading();
  }
}
