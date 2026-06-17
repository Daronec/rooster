import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/progress/app_progress_bar.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppProgressBar строит полосу и внутренний AnimatedContainer', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithAppTheme(
        const Center(child: AppProgressBar(maximum: 100, progress: 50)),
      ),
    );

    expect(find.byType(AppProgressBar), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsOneWidget);
  });
}
