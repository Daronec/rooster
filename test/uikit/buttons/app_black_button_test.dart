import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/buttons/app_black_button.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppBlackButton вызывает onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWithAppTheme(
        AppBlackButton(
          size: AppButtonSize.medium,
          onPressed: () => tapped = true,
          child: const Text('Чёрная'),
        ),
      ),
    );

    await tester.tap(find.text('Чёрная'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
