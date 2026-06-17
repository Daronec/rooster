import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/desktop/planning_desktop_content.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/desktop/planning_desktop_failure.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/desktop/planning_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран планирования (desktop).
class PlanningScreenDesktop extends StatelessWidget {
  /// Создаёт экран.
  const PlanningScreenDesktop({required this.wm, super.key});

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) => const PlanningDesktopLoading(),
      builder: (context, data) => PlanningDesktopContent(wm: wm),
      failureBuilder: (context, exception, last) {
        return PlanningDesktopFailure(
          wm: wm,
          error: exception ?? Exception('planning_stream'),
        );
      },
    );
  }
}
