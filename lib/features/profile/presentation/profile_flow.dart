import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Вкладка «Профиль».
@RoutePage(name: 'ProfileFlowRoute')
class ProfileFlow extends StatelessWidget {
  /// Создаёт flow.
  const ProfileFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
