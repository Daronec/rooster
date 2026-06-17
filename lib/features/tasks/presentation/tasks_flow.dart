import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Вкладка «Задачи».
@RoutePage(name: 'TasksFlowRoute')
class TasksFlow extends StatelessWidget {
  /// Создаёт flow.
  const TasksFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
