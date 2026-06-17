import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppPrimaryButton вызывает onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWithAppTheme(
        AppPrimaryButton(
          size: AppButtonSize.medium,
          onPressed: () => tapped = true,
          child: const Text('ОК'),
        ),
      ),
    );

    await tester.tap(find.text('ОК'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
