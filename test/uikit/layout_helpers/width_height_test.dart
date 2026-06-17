import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';

void main() {
  testWidgets('Width задаёт SizedBox с шириной', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Width(12.5))),
    );
    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.width, 12.5);
    expect(box.height, isNull);
  });

  testWidgets('Height задаёт SizedBox с высотой', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Height(20))),
    );
    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, 20.0);
    expect(box.width, isNull);
  });
}
