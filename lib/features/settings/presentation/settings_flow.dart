import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Flow настроек (вкладка и отдельный стек на мобильном).
@RoutePage(name: 'SettingsFlowRoute')
class SettingsFlow extends StatelessWidget {
  /// Создаёт flow.
  const SettingsFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
