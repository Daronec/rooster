// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';

/// Строки приоритета задачи (`createTask.priority_*` в JSON локализации).
final class TaskPriorityStrings {
  TaskPriorityStrings._();

  static String label(BuildContext context, TaskPriorityEntity priority) {
    return FlutterI18n.translate(
      context,
      'createTask.priority_${priority.name}',
    );
  }
}
