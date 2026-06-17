import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/others/app_divider.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppDivider отображает один Divider', (tester) async {
    await tester.pumpWidget(wrapWithAppTheme(const AppDivider()));
    expect(find.byType(Divider), findsOneWidget);
  });
}
