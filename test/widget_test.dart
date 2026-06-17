import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test: MaterialApp builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('OK'))),
      ),
    );
    expect(find.text('OK'), findsOneWidget);
  });
}
