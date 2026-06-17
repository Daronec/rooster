import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/others/app_tooltip_widget.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppTooltipWidget оборачивает child в Tooltip', (tester) async {
    await tester.pumpWidget(
      wrapWithAppTheme(
        const AppTooltipWidget(message: 'Подсказка', child: Text('Контент')),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.text('Контент'), findsOneWidget);
  });
}
