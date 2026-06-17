import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Вкладка «Списки».
@RoutePage(name: 'TaskListsFlowRoute')
class TaskListsFlow extends StatelessWidget {
  /// Создаёт flow.
  const TaskListsFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
