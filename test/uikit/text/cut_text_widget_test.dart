import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/text/cut_text_widget.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('CutTextWidget показывает текст и вызывает onTap по кнопке', (
    tester,
  ) async {
    var expanded = false;
    await tester.pumpWidget(
      wrapWithAppTheme(
        SizedBox(
          width: 200,
          child: CutTextWidget(
            text: 'Короткий',
            maxLines: 2,
            buttonTitle: 'Подробнее',
            onTap: () => expanded = true,
          ),
        ),
      ),
    );

    expect(find.text('Короткий'), findsOneWidget);
    expect(find.text('Подробнее'), findsOneWidget);

    await tester.tap(find.text('Подробнее'));
    await tester.pump();
    expect(expanded, isTrue);
  });
}
