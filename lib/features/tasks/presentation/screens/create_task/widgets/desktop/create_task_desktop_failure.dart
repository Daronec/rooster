import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Полноэкранная ошибка на экране создания задачи (desktop).
class CreateTaskDesktopFailure extends StatelessWidget {
  /// Создаёт виджет.
  const CreateTaskDesktopFailure({
    required this.wm,
    required this.message,
    required this.onRetry,
    super.key,
  });

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  /// Текст ошибки.
  final String message;

  /// Повтор действия.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      appBar: DefaultAppBar(
        title: Text(
          wm.isEditingTask
              ? CreateTasksStrings.editScreenTitle(context)
              : CreateTasksStrings.screenTitle(context),
        ),
        onBackButtonTap: wm.onCancel,
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(message, style: AppTextStyle.t14.value),
            const Height(AppSizes.double16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(CreateTasksStrings.retry(context)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Блок ошибки загрузки списков внутри формы (desktop).
class CreateTaskDesktopListsFailurePanel extends StatelessWidget {
  /// Создаёт виджет.
  const CreateTaskDesktopListsFailurePanel({
    required this.onRetry,
    super.key,
  });

  /// Повтор загрузки списков.
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          CreateTasksStrings.listsError(context),
          style: AppTextStyle.t14.value,
        ),
        const Height(AppSizes.double8),
        FilledButton.tonal(
          onPressed: onRetry,
          child: Text(CreateTasksStrings.retry(context)),
        ),
      ],
    );
  }
}
