import 'package:flutter/material.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/mobile/planning_mobile_content.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/mobile/planning_mobile_failure.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/mobile/planning_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран планирования (mobile).
class PlanningScreenMobile extends StatelessWidget {
  /// Создаёт экран.
  const PlanningScreenMobile({required this.wm, super.key});

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) => const PlanningMobileLoading(),
      builder: (context, data) => PlanningMobileContent(wm: wm),
      failureBuilder: (context, exception, last) {
        return PlanningMobileFailure(
          wm: wm,
          error: exception ?? Exception('planning_stream'),
        );
      },
    );
  }
}
