import 'package:flutter/foundation.dart';

/// Application constants.
abstract class AppConsts {
  /// App default request timeout.
  static const timeout = Duration(seconds: 30);

  /// Domain.
  static const domain = 'api.xxx.ru';

  /// Default in-app minimum version.
  static const kDefaultMinimumVersion = '1.0.0';

  /// Default in-app current version.
  static const kDefaultActualVersion = '1.0.0';

  /// Google Play store link.
  static const androidStoreLink =
      'https://play.google.com/store/apps/details?id=com.xxx.xx.app&hl=ru';

  /// App Store link.
  static const iosStoreLink = 'https://apps.apple.com/us/app/xxx/id';

  /// Returns store link based on which platform user is.
  ///
  /// Android and iOS returns [androidStoreLink] and [iosStoreLink] respectively,
  /// any other returns `null`.
  static String? get storeLink => switch (defaultTargetPlatform) {
    TargetPlatform.android => androidStoreLink,
    TargetPlatform.iOS => iosStoreLink,
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.fuchsia => null,
  };
}
