import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';

/// Пустое состояние списка задач.
final class TasksGroupedListEmptyState extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        TasksStrings.emptyState(context),
        textAlign: TextAlign.center,
      ),
    );
  }
}

