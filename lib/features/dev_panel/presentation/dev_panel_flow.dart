import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Dev: очередь синхронизации и сеть.
@RoutePage(name: 'DevPanelFlowRoute')
class DevPanelFlow extends StatelessWidget {
  /// Создаёт flow.
  const DevPanelFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
