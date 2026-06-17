import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/buttons/app_tab.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppTab показывает label и вызывает onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWithAppTheme(
        Center(
          child: AppTab(
            isActive: true,
            width: 120,
            label: 'Вкладка',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Вкладка'), findsOneWidget);
    await tester.tap(find.text('Вкладка'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
