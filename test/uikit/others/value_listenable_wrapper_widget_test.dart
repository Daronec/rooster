import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/others/value_listenable_wrapper_widget.dart';

void main() {
  testWidgets('показывает child только при истинном conditionBuilder', (
    tester,
  ) async {
    final notifier = ValueNotifier<int>(0);
    addTearDown(notifier.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableWrapperWidget<int>(
          valueListenable: notifier,
          conditionBuilder: (v) => v > 0,
          child: const Text('shown'),
        ),
      ),
    );

    expect(find.text('shown'), findsNothing);

    notifier.value = 1;
    await tester.pump();
    expect(find.text('shown'), findsOneWidget);

    notifier.value = 0;
    await tester.pump();
    expect(find.text('shown'), findsNothing);
  });
}
