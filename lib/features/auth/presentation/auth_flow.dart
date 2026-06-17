import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Корневой flow авторизации.
@RoutePage(name: 'AuthFlowRoute')
class AuthFlow extends StatelessWidget {
  /// Создаёт flow.
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
