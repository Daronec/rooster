import 'package:flutter/rendering.dart';

/// Frequent sizes.
abstract class AppSizes {
  /// Value double 0.
  static const double0 = 0.0;

  /// Value double 0,5.
  static const double05 = 0.5;

  /// Value double 1.
  static const double1 = 1.0;

  /// Value double 2.
  static const double2 = 2.0;

  /// Value double 4.
  static const double4 = 4.0;

  /// Value double 6.
  static const double6 = 6.0;

  /// Value double 8.
  static const double8 = 8.0;

  /// Value double 10.
  static const double10 = 10.0;

  /// Value double 11.
  static const double11 = 11.0;

  /// Value double 12.
  static const double12 = 12.0;

  /// Value double 14.
  static const double14 = 14.0;

  /// Value double 16.
  static const double16 = 16.0;

  /// Value double 18.
  static const double18 = 18.0;

  /// Value double 20.
  static const double20 = 20.0;

  /// Value double 22.
  static const double22 = 22.0;

  /// Value double 24.
  static const double24 = 24.0;

  /// Value double 28.
  static const double28 = 28.0;

  /// Value double 32.
  static const double32 = 32.0;

  /// Value double 34.
  static const double34 = 34.0;

  /// Value double 36.
  static const double36 = 36.0;

  /// Value double 40.
  static const double40 = 40.0;

  /// Value double 44.
  static const double44 = 44.0;

  /// Value double 48.
  static const double48 = 48.0;

  /// Value double 50.
  static const double50 = 50.0;

  /// Value double 56.
  static const double56 = 56.0;

  /// Value double 60.
  static const double60 = 60.0;

  /// Value double 64.
  static const double64 = 64.0;

  /// Value double 68.
  static const double68 = 68.0;

  /// Value double 70.
  static const double70 = 70.0;

  /// Value double 70,8 (ширина контейнера активного пункта нижней навигации).
  static const double70_8 = 70.8;

  /// Value double 72.
  static const double72 = 72.0;

  /// Value double 76.
  static const double76 = 76.0;

  /// Value double 80.
  static const double80 = 80.0;

  /// Value double 82.
  static const double82 = 82.0;

  /// Value double 84.
  static const double84 = 84.0;

  /// Value double 88.
  static const double88 = 88.0;

  /// Value double 90.
  static const double90 = 90.0;

  /// Value double 92.
  static const double92 = 92.0;

  /// Value double 94.
  static const double94 = 94.0;

  /// Value double 96.
  static const double96 = 96.0;

  /// Value double 100.
  static const double100 = 100.0;

  /// Value double 116.
  static const double116 = 116.0;

  /// Value double 120.
  static const double120 = 120.0;

  /// Value double 128.
  static const double128 = 128.0;

  /// Value double 140.
  static const double140 = 140.0;

  /// Value double 140.
  static const double144 = 144.0;

  /// Value double 152.
  static const double152 = 152.0;

  /// Value double 156.
  static const double156 = 156.0;

  /// Value double 160.
  static const double160 = 160.0;

  /// Value double 166.
  static const double166 = 166.0;

  /// Value double 170.
  static const double170 = 170.0;

  /// Value double 192.
  static const double192 = 192.0;

  /// Value double 200.
  static const double200 = 200.0;

  /// Value double 210.
  static const double210 = 210.0;

  /// Value double 220.
  static const double220 = 220.0;

  /// Value double 240.
  static const double240 = 240.0;

  /// Value double 256.
  static const double256 = 256.0;

  /// Value double 260.
  static const double260 = 260.0;

  /// Value double 282.
  static const dobule282 = 282.0;

  /// Value double 300.
  static const double300 = 300.0;

  /// Value double 320.
  static const double320 = 320.0;

  /// Value double 343.
  static const double343 = 343.0;

  /// Value double 350.
  static const double350 = 350.0;

  /// Value double 386.
  static const double386 = 386.0;

  /// Value double 400.
  static const double400 = 400.0;

  /// Value double 412.
  static const double412 = 412.0;

  /// Value double 440.
  static const double440 = 440.0;

  /// Value double 488.
  static const double488 = 488.0;

  /// Value double 500.
  static const double500 = 500.0;

  /// Value double 600.
  static const double600 = 600.0;

  /// Value double 800.
  static const double800 = 800.0;

  /// Value double 1000.
  static const double1000 = 1000.0;

  /// Default lenght for mobile shimmer effect.
  static const kDefaultMobileShimmerLenght = 220.0;

  /// App Bar Height.
  static const appBarHeight = 56.0;

  /// App bar height with additional content (image, subtitle, etc).
  static const enlargedAppBarHeight = 64.0;

  /// App Bar Height for Desktop.
  static const desktopAppBarHeight = 96.0;

  /// High App Bar Height for Desktop.
  static const desktopHighAppBarHeight = 128.0;

  /// Maximum width of the mobile layout.
  static const kMobileWidth = 768.0;

  /// Side bar width for desktop.
  static const kSidebarWidth = 400.0;

  /// Side bar width for desktop.
  static const kSidebarMaxWidth = 600.0;

  /// Huge side bar width for desktop.
  static const kSidebarHugeWidth = 800.0;

  /// Hour height.
  static const kHourHeight = 55.0;

  /// Border radius with value 2.
  static const borderRadius2 = BorderRadius.all(
    Radius.circular(AppSizes.double2),
  );

  /// Border radius with value 4.
  static const borderRadius4 = BorderRadius.all(
    Radius.circular(AppSizes.double4),
  );

  /// Border radius with value 6.
  static const borderRadius6 = BorderRadius.all(
    Radius.circular(AppSizes.double6),
  );

  /// Border radius with value 8.
  static const borderRadius8 = BorderRadius.all(
    Radius.circular(AppSizes.double8),
  );

  /// Border radius with value 12.
  static const borderRadius12 = BorderRadius.all(
    Radius.circular(AppSizes.double12),
  );

  /// Border radius with value 16.
  static const borderRadius16 = BorderRadius.all(
    Radius.circular(AppSizes.double16),
  );

  /// Скругление только верхних углов (16 px).
  static const borderRadiusTop16 = BorderRadius.only(
    topLeft: Radius.circular(AppSizes.double16),
    topRight: Radius.circular(AppSizes.double16),
  );

  /// Border radius with value 20.
  static const borderRadius20 = BorderRadius.all(
    Radius.circular(AppSizes.double20),
  );

  /// Border radius with value 24.
  static const borderRadius24 = BorderRadius.all(
    Radius.circular(AppSizes.double24),
  );

  /// Border radius with value 32.
  static const borderRadius32 = BorderRadius.all(
    Radius.circular(AppSizes.double32),
  );

  /// Border radius with value 36.
  static const borderRadius36 = BorderRadius.all(
    Radius.circular(AppSizes.double36),
  );

  /// Border radius with value 40.
  static const borderRadius40 = BorderRadius.all(
    Radius.circular(AppSizes.double40),
  );

  /// Edge insets all 16.
  static const edgeInsetsAll16 = EdgeInsets.all(double16);

  /// Горизонтально [double12], вертикально [double16] — строки списков (системы, сцены).
  static const edgeInsetsSymmetricH12V16 = EdgeInsets.symmetric(
    horizontal: double12,
    vertical: double16,
  );
}
