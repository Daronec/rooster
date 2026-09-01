import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Вкладка «AI Чат»
@RoutePage(name: 'AiChatFlowRoute')
class AiChatFlow extends StatelessWidget {
  /// Создаёт flow.
  const AiChatFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
