import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/value_listenable_builder/duo_listenable_builder.dart';

void main() {
  testWidgets('DuoListenableBuilder обновляет UI при смене обоих listenable', (
    tester,
  ) async {
    final first = ValueNotifier<int>(1);
    final second = ValueNotifier<String>('a');

    await tester.pumpWidget(
      MaterialApp(
        home: DuoListenableBuilder<int, String>(
          firstListenable: first,
          secondListenable: second,
          builder: (context, f, s, child) {
            return Text('$f-$s');
          },
        ),
      ),
    );

    expect(find.text('1-a'), findsOneWidget);

    first.value = 2;
    await tester.pump();
    expect(find.text('2-a'), findsOneWidget);

    second.value = 'b';
    await tester.pump();
    expect(find.text('2-b'), findsOneWidget);

    first.dispose();
    second.dispose();
  });
}
