import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/others/pop_scope_wrapper.dart';

void main() {
  testWidgets('PopScopeWrapper отображает child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PopScopeWrapper<void>(
          shouldPop: () async => false,
          child: const Text('inside'),
        ),
      ),
    );

    expect(find.text('inside'), findsOneWidget);
  });
}
