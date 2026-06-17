import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Полноэкранная загрузка при старте экрана создания задачи (desktop).
class CreateTaskDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const CreateTaskDesktopLoading({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

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
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(CreateTasksStrings.bootstrapLoading(context)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Блок загрузки списков внутри формы (desktop).
class CreateTaskDesktopListsLoadingPanel extends StatelessWidget {
  /// Создаёт виджет.
  const CreateTaskDesktopListsLoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const Height(AppSizes.double16),
            Text(CreateTasksStrings.listsLoading(context)),
          ],
        ),
      ),
    );
  }
}
