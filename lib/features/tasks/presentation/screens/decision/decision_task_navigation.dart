import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/navigation/app_router.dart';

/// Навигация из экранов раздела «Решения» к задачам.
abstract final class DecisionTaskNavigation {
  /// Открывает детали задачи внутри текущего [DecisionFlowRoute].
  static Future<void> openTaskDetail(
    BuildContext context, {
    required String taskId,
  }) async {
    await context.router.push<void>(TaskDetailRoute(taskId: taskId));
  }
}
