import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/strings/task_detail_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Загрузка экрана деталей задачи (desktop).
class TaskDetailDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const TaskDetailDesktopLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(TaskDetailStrings.screenTitle(context)),
        onBackButtonTap: () {
          context.router.maybePop();
        },
      ),
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(TaskDetailStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
