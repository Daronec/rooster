import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/util/app_consts.dart';

void main() {
  group('AppConsts', () {
    test('таймаут и версии по умолчанию', () {
      expect(AppConsts.timeout, const Duration(seconds: 30));
      expect(AppConsts.kDefaultMinimumVersion, '1.0.0');
      expect(AppConsts.kDefaultActualVersion, '1.0.0');
    });

    test('storeLink соответствует платформе', () {
      final link = AppConsts.storeLink;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          expect(link, AppConsts.androidStoreLink);
        case TargetPlatform.iOS:
          expect(link, AppConsts.iosStoreLink);
        default:
          expect(link, isNull);
      }
    });
  });
}
