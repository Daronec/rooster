import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/buttons/app_switch.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppSwitch отображает Switch с переданным value', (tester) async {
    await tester.pumpWidget(
      wrapWithAppTheme(const Center(child: AppSwitch(value: true))),
    );

    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.value, isTrue);
  });

  testWidgets('onSwitch вызывается при переключении', (tester) async {
    var last = false;
    await tester.pumpWidget(
      wrapWithAppTheme(
        Center(child: AppSwitch(value: false, onSwitch: (v) => last = v)),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(last, isTrue);
  });
}
