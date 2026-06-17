import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/task_detail_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Ошибка или отсутствие задачи на экране деталей (mobile).
class TaskDetailMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const TaskDetailMobileFailure({
    required this.wm,
    required this.exception,
    super.key,
  });

  /// Widget model экрана деталей.
  final TaskDetailScreenWidgetModel wm;

  /// Исключение с причиной.
  final Exception? exception;

  @override
  Widget build(BuildContext context) {
    final message =
        TaskDetailStrings.messageForDetailFailure(context, exception);
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TaskDetailStrings.screenTitle(context)),
        onBackButtonTap: () {
          context.router.maybePop();
        },
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: wm.retryDetail,
              child: Text(TaskDetailStrings.retryBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
