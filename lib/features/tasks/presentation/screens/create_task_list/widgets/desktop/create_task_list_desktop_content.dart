import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/widgets/mobile/create_task_list_mobile_content.dart';

/// Форма создания списка задач (desktop): та же вёрстка, что и на mobile.
class CreateTaskListDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const CreateTaskListDesktopContent({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskListScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: CreateTaskListMobileContent(wm: wm),
      ),
    );
  }
}
