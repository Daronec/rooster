import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/value_listenable_builder/trio_listenable_builder.dart';

void main() {
  testWidgets('TrioListenableBuilder передаёт три значения в builder', (
    tester,
  ) async {
    final first = ValueNotifier<int>(10);
    final second = ValueNotifier<bool>(false);
    final third = ValueNotifier<double>(1.5);

    await tester.pumpWidget(
      MaterialApp(
        home: TrioListenableBuilder<int, bool, double>(
          firstListenable: first,
          secondListenable: second,
          thirdListenable: third,
          builder: (context, f, s, t, child) {
            return Text('$f-$s-$t');
          },
        ),
      ),
    );

    expect(find.text('10-false-1.5'), findsOneWidget);

    third.value = 2.0;
    await tester.pump();
    expect(find.text('10-false-2.0'), findsOneWidget);

    first.dispose();
    second.dispose();
    third.dispose();
  });
}
