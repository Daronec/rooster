import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/buttons/app_gray_button.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppGrayButton вызывает onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWithAppTheme(
        AppGrayButton(
          size: AppButtonSize.medium,
          onPressed: () => tapped = true,
          child: const Text('Действие'),
        ),
      ),
    );

    await tester.tap(find.text('Действие'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
