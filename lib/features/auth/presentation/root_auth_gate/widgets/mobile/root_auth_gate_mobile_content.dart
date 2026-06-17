import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/mobile/root_auth_gate_mobile_loading.dart';

/// Контент корневого шлюза (mobile): ожидание и переход в основной граф.
class RootAuthGateMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const RootAuthGateMobileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const RootAuthGateMobileLoading();
  }
}
