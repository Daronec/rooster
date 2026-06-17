import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/others/app_vertical_divider.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppVerticalDivider отображает один VerticalDivider', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithAppTheme(const AppVerticalDivider()));
    expect(find.byType(VerticalDivider), findsOneWidget);
  });
}
