import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/uikit/others/app_bar_title_widget.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('AppBarTitleWidget показывает title и subtitle', (tester) async {
    await tester.pumpWidget(
      wrapWithAppTheme(
        const AppBarTitleWidget(title: 'Заголовок', subtitle: 'Подзаголовок'),
      ),
    );

    expect(find.text('Заголовок'), findsOneWidget);
    expect(find.text('Подзаголовок'), findsOneWidget);
  });

  testWidgets('без subtitle — только title', (tester) async {
    await tester.pumpWidget(
      wrapWithAppTheme(const AppBarTitleWidget(title: 'Заголовок')),
    );

    expect(find.text('Заголовок'), findsOneWidget);
  });
}
