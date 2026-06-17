// ignore_for_file: avoid-non-null-assertion, avoid-long-files

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_sizes_scheme.tailor.dart';

/// Naming-dimension table:
/// Microscopic - 1
/// Tiny - 2
/// Small - 4
/// Medium - 8
/// Standard - 12
/// General - 16
/// Big - 20
/// Huge - 24
/// Massive - 32
/// Gigantic - 40
/// Considerable - 56
/// Enormous - 80

/// App text style scheme.
@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppSizesScheme extends ThemeExtension<AppSizesScheme>
    with _$AppSizesSchemeTailorMixin {

  /// App sizes scheme for app.
  const AppSizesScheme({
    required this.empty,
    required this.paddingStandard,
    required this.separatorMicroscopic,
    required this.paddingMicroscopic,
    required this.paddingGeneral,
    required this.borderRadiusSmall,
    required this.borderRadiusMedium,
    required this.borderRadiusStandart,
    required this.borderRadiusGeneral,
    required this.borderRadiusHuge,
    required this.borderRadiusLarge,
    required this.paddingMedium,
    required this.paddingSmall,
    required this.strokeGeneral,
    required this.separatorSmall,
    required this.paddingTiny,
    required this.loaderSizeMinimum,
    required this.loaderSizeMaximum,
    required this.paddingBig,
    required this.paddingHuge,
    required this.paddingMassive,
    required this.paddingGigantic,
    required this.paddingConsiderable,
    required this.paddingEnormous,
    required this.iconSizeStandart,
    required this.iconSizeGeneral,
    required this.iconSizeHuge,
    required this.iconSizeMassive,
    required this.iconSizeGigantic,
    required this.iconsSizeEnormous,
    required this.dialogSizeMaxiumum,
    required this.dialogSizeMinimum,
    required this.calendarHourHeight,
    required this.generalTileHeight,
    required this.mobileShimmerWidth,
    required this.codeInputWidth,
    required this.codeInputHeight,
    required this.mobileWidth,
    required this.sidebarGeneral,
    required this.sidebarBig,
    required this.sidebarHuge,
  });

  /// Base app text theme.
  AppSizesScheme.base()
    : separatorMicroscopic = AppSizes.double1,
      empty = AppSizes.double0,
      paddingGeneral = AppSizes.double16,
      borderRadiusSmall = AppSizes.borderRadius4,
      borderRadiusMedium = AppSizes.borderRadius8,
      borderRadiusStandart = AppSizes.borderRadius12,
      borderRadiusGeneral = AppSizes.borderRadius16,
      borderRadiusHuge = AppSizes.borderRadius24,
      borderRadiusLarge = AppSizes.borderRadius36,
      paddingMicroscopic = AppSizes.double1,
      paddingMedium = AppSizes.double8,
      strokeGeneral = AppSizes.double2,
      paddingTiny = AppSizes.double2,
      separatorSmall = AppSizes.double2,
      loaderSizeMaximum = AppSizes.double24,
      loaderSizeMinimum = AppSizes.double2,
      paddingSmall = AppSizes.double4,
      paddingStandard = AppSizes.double12,
      iconSizeStandart = AppSizes.double12,
      iconSizeGeneral = AppSizes.double16,
      iconSizeHuge = AppSizes.double24,
      iconSizeMassive = AppSizes.double32,
      paddingBig = AppSizes.double20,
      paddingHuge = AppSizes.double24,
      paddingMassive = AppSizes.double32,
      paddingGigantic = AppSizes.double40,
      paddingConsiderable = AppSizes.double56,
      paddingEnormous = AppSizes.double80,
      iconSizeGigantic = AppSizes.double40,
      dialogSizeMaxiumum = AppSizes.double600,
      dialogSizeMinimum = AppSizes.double400,
      calendarHourHeight = AppSizes.kHourHeight,
      iconsSizeEnormous = AppSizes.double80,
      generalTileHeight = AppSizes.double56,
      mobileShimmerWidth = AppSizes.kDefaultMobileShimmerLenght,
      codeInputWidth = AppSizes.double48,
      codeInputHeight = AppSizes.double56,
      mobileWidth = AppSizes.kMobileWidth,
      sidebarGeneral = AppSizes.kSidebarWidth,
      sidebarBig = AppSizes.kSidebarMaxWidth,
      sidebarHuge = AppSizes.kSidebarHugeWidth;
  /// Empty padding / border position for positioned widget.
  ///
  /// Default value is `0.0`.
  @override
  final double empty;

  /// Default height for separators.
  ///
  /// Default value is `1.0`.
  @override
  final double separatorMicroscopic;

  /// Height for separators for more distinct separators.
  ///
  /// Default value is `2.0`.
  @override
  final double separatorSmall;

  /// Default value is `1.0`.
  @override
  final double paddingMicroscopic;

  /// Default value is `2.0`.
  @override
  final double paddingTiny;

  /// Default value is `4.0`.
  @override
  final double paddingSmall;

  /// Default value is `8.0`.
  @override
  final double paddingMedium;

  /// Default value is `12.0`.
  @override
  final double paddingStandard;

  /// Default value is `16.0`.
  @override
  final double paddingGeneral;

  /// Default value is `20.0`.
  @override
  final double paddingBig;

  /// Default value is `24.0`.
  @override
  final double paddingHuge;

  /// Default value is `32.0`.
  @override
  final double paddingMassive;

  /// Default value is `40.0`.
  @override
  final double paddingGigantic;

  /// Default value is `56.0`.
  @override
  final double paddingConsiderable;

  /// Default value is `80.0`.
  @override
  final double paddingEnormous;

  /// Small border radius used throughout the app.
  ///
  /// Default value is `BorderRadius.circular(4.0)`.
  @override
  final BorderRadius borderRadiusSmall;

  /// Medium border radius used throughout the app.
  ///
  /// Default value is `BorderRadius.circular(8.0)`.
  @override
  final BorderRadius borderRadiusMedium;

  /// Standart border radius used throughout the app.
  ///
  /// Default value is `BorderRadius.circular(12.0)`.
  @override
  final BorderRadius borderRadiusStandart;

  /// General border radius used throughout the app.
  ///
  /// Default value is `BorderRadius.circular(16.0)`.
  @override
  final BorderRadius borderRadiusGeneral;

  /// Huge border radius used throughout the app.
  ///
  /// Default value is `BorderRadius.circular(24.0)`.
  @override
  final BorderRadius borderRadiusHuge;

  /// Large border radius used throughout the app.
  ///
  /// Default value is `BorderRadius.circular(36.0)`.
  @override
  final BorderRadius borderRadiusLarge;

  /// Default stroke width of different borders in app.
  ///
  /// Default value is `2.0`.
  @override
  final double strokeGeneral;

  /// Circular progress indicator minimum size.
  ///
  /// Used in PTR to determine loader's size on pull progress.
  ///
  /// Default value is `2.0`.
  @override
  final double loaderSizeMinimum;

  /// Circular progress indicator maximum size.
  ///
  /// Used in PTR to determine loader's size on pull progress.
  ///
  /// Default value is `24.0`.
  @override
  final double loaderSizeMaximum;

  /// Standart size of icons in app.
  ///
  /// Default value is `12.0`.
  @override
  final double iconSizeStandart;

  /// General size of icons in app.
  ///
  /// Default value is `16.0`.
  @override
  final double iconSizeGeneral;

  /// Huge size of icons in app.
  ///
  /// Default value is `24.0`.
  @override
  final double iconSizeHuge;

  /// Massive size of icon buttons in app.
  ///
  /// Default value is `32.0`.
  @override
  final double iconSizeMassive;

  /// Gigantic size of icons.
  ///
  /// Default value is `40.0`.
  @override
  final double iconSizeGigantic;

  /// Enormous size of action buttons/action header icons in app.
  ///
  /// Default value is `80.0`.
  @override
  final double iconsSizeEnormous;

  /// App dialog minimum size.
  ///
  /// App dialogs on desktop cannot be smaller than this.
  ///
  /// For more info, see `app_dialog.dart`.
  ///
  /// Default value is `400.0`.
  @override
  final double dialogSizeMinimum;

  /// App dialog maxiumum size.
  ///
  /// App dialogs on desktop cannot be bigger than this.
  ///
  /// For more info, see `app_dialog.dart`.
  ///
  /// Default value is `600.0`.
  @override
  final double dialogSizeMaxiumum;

  /// Calendar grid hour height.
  ///
  /// Used for building grids/fot calculating events position on grid.
  ///
  /// Default value is `55.0`.
  @override
  final double calendarHourHeight;

  /// General tile height of app.
  ///
  /// Different list tiles/app widget uses this dimension as height.
  ///
  /// Default value is `56.0`.
  @override
  final double generalTileHeight;

  /// General shimmer width for mobile layout.
  ///
  /// Used for drawing shimmer lists on a lot of different screens throughout the app.
  ///
  /// See `search_shimmer.dart` for example.
  ///
  /// Default value is `220.0`.
  @override
  final double mobileShimmerWidth;

  /// General OTP code input width.
  ///
  /// Used on `otp_input_screen.dart` for inputs width.
  ///
  /// Default value is `48.0`.
  @override
  final double codeInputWidth;

  /// General OTP code input height.
  ///
  /// Used on `otp_input_screen.dart` for inputs height.
  ///
  /// Default value is `56.0`.
  @override
  final double codeInputHeight;

  /// General size of sidebar.
  ///
  /// Sidebar is used on desktop for displaying various screens of mobile layout.
  ///
  /// For more info, see `app_side_bar_wrapper.dart`.
  ///
  /// Default value is `400.0`.
  @override
  final double sidebarGeneral;

  /// Big size of sidebar.
  ///
  /// Sidebar is used on desktop for displaying various screens of mobile layout.
  ///
  /// For more info, see `app_side_bar_wrapper.dart`.
  ///
  /// Default value is `600.0`.
  @override
  final double sidebarBig;

  /// Huge size of sidebar.
  ///
  /// Sidebar is used on desktop for displaying various screens of mobile layout.
  ///
  /// For more info, see `app_side_bar_wrapper.dart`.
  ///
  /// Default value is `800.0`.
  @override
  final double sidebarHuge;

  /// General width of mobile screen.
  ///
  /// Any screen wider than that value considered a desktop device, so desktop layout is used.
  ///
  /// In other cases mobile layout is used.
  ///
  /// For more info, see `base_widget.dart`.
  ///
  /// Default value is `768.0`.
  @override
  final double mobileWidth;

  /// Get [AppSizesScheme] from [BuildContext].
  static AppSizesScheme of(BuildContext context) =>
      Theme.of(context).extension<AppSizesScheme>()!;

  @override
  AppSizesScheme lerp(
    covariant ThemeExtension<AppSizesScheme>? other,
    double t,
    // ignore: avoid-long-functions
  ) {
    if (other is! AppSizesScheme) return this;

    final otherSizes = other;

    return AppSizesScheme(
      empty: lerpDouble(empty, otherSizes.empty, t) ?? empty,
      paddingStandard:
          lerpDouble(paddingStandard, otherSizes.paddingStandard, t) ??
          paddingStandard,
      separatorMicroscopic:
          lerpDouble(
            separatorMicroscopic,
            otherSizes.separatorMicroscopic,
            t,
          ) ??
          separatorMicroscopic,
      paddingMicroscopic:
          lerpDouble(paddingMicroscopic, otherSizes.paddingMicroscopic, t) ??
          paddingMicroscopic,
      paddingGeneral:
          lerpDouble(paddingGeneral, otherSizes.paddingGeneral, t) ??
          paddingGeneral,
      borderRadiusSmall:
          BorderRadius.lerp(
            borderRadiusSmall,
            otherSizes.borderRadiusSmall,
            t,
          ) ??
          borderRadiusSmall,
      borderRadiusMedium:
          BorderRadius.lerp(
            borderRadiusMedium,
            otherSizes.borderRadiusMedium,
            t,
          ) ??
          borderRadiusMedium,
      borderRadiusStandart:
          BorderRadius.lerp(
            borderRadiusStandart,
            otherSizes.borderRadiusStandart,
            t,
          ) ??
          borderRadiusStandart,
      borderRadiusGeneral:
          BorderRadius.lerp(
            borderRadiusGeneral,
            otherSizes.borderRadiusGeneral,
            t,
          ) ??
          borderRadiusGeneral,
      borderRadiusHuge:
          BorderRadius.lerp(borderRadiusHuge, otherSizes.borderRadiusHuge, t) ??
          borderRadiusHuge,
      borderRadiusLarge:
          BorderRadius.lerp(
            borderRadiusLarge,
            otherSizes.borderRadiusLarge,
            t,
          ) ??
          borderRadiusLarge,
      paddingMedium:
          lerpDouble(paddingMedium, otherSizes.paddingMedium, t) ??
          paddingMedium,
      paddingSmall:
          lerpDouble(paddingSmall, otherSizes.paddingSmall, t) ?? paddingSmall,
      strokeGeneral:
          lerpDouble(strokeGeneral, otherSizes.strokeGeneral, t) ??
          strokeGeneral,
      separatorSmall:
          lerpDouble(separatorSmall, otherSizes.separatorSmall, t) ??
          separatorSmall,
      paddingTiny:
          lerpDouble(paddingTiny, otherSizes.paddingTiny, t) ?? paddingTiny,
      loaderSizeMinimum:
          lerpDouble(loaderSizeMinimum, otherSizes.loaderSizeMinimum, t) ??
          loaderSizeMinimum,
      loaderSizeMaximum:
          lerpDouble(loaderSizeMaximum, otherSizes.loaderSizeMaximum, t) ??
          loaderSizeMaximum,
      paddingBig:
          lerpDouble(paddingBig, otherSizes.paddingBig, t) ?? paddingBig,
      paddingHuge:
          lerpDouble(paddingHuge, otherSizes.paddingHuge, t) ?? paddingHuge,
      paddingMassive:
          lerpDouble(paddingMassive, otherSizes.paddingMassive, t) ??
          paddingMassive,
      paddingGigantic:
          lerpDouble(paddingGigantic, otherSizes.paddingGigantic, t) ??
          paddingGigantic,
      paddingConsiderable:
          lerpDouble(paddingConsiderable, otherSizes.paddingConsiderable, t) ??
          paddingConsiderable,
      paddingEnormous:
          lerpDouble(paddingEnormous, otherSizes.paddingEnormous, t) ??
          paddingEnormous,
      iconSizeStandart:
          lerpDouble(iconSizeStandart, otherSizes.iconSizeStandart, t) ??
          iconSizeStandart,
      iconSizeGeneral:
          lerpDouble(iconSizeGeneral, otherSizes.iconSizeGeneral, t) ??
          iconSizeGeneral,
      iconSizeHuge:
          lerpDouble(iconSizeHuge, otherSizes.iconSizeHuge, t) ?? iconSizeHuge,
      iconSizeMassive:
          lerpDouble(iconSizeMassive, otherSizes.iconSizeMassive, t) ??
          iconSizeMassive,
      iconSizeGigantic:
          lerpDouble(iconSizeGigantic, otherSizes.iconSizeGigantic, t) ??
          iconSizeGigantic,
      iconsSizeEnormous:
          lerpDouble(iconsSizeEnormous, otherSizes.iconsSizeEnormous, t) ??
          iconsSizeEnormous,
      dialogSizeMaxiumum:
          lerpDouble(dialogSizeMaxiumum, otherSizes.dialogSizeMaxiumum, t) ??
          dialogSizeMaxiumum,
      dialogSizeMinimum:
          lerpDouble(dialogSizeMinimum, otherSizes.dialogSizeMinimum, t) ??
          dialogSizeMinimum,
      calendarHourHeight:
          lerpDouble(calendarHourHeight, otherSizes.calendarHourHeight, t) ??
          calendarHourHeight,
      generalTileHeight:
          lerpDouble(generalTileHeight, otherSizes.generalTileHeight, t) ??
          generalTileHeight,
      mobileShimmerWidth:
          lerpDouble(mobileShimmerWidth, otherSizes.mobileShimmerWidth, t) ??
          mobileShimmerWidth,
      codeInputWidth:
          lerpDouble(codeInputWidth, otherSizes.codeInputWidth, t) ??
          codeInputWidth,
      codeInputHeight:
          lerpDouble(codeInputHeight, otherSizes.codeInputHeight, t) ??
          codeInputHeight,
      mobileWidth:
          lerpDouble(mobileWidth, otherSizes.mobileWidth, t) ?? mobileWidth,
      sidebarGeneral:
          lerpDouble(sidebarGeneral, otherSizes.sidebarGeneral, t) ??
          sidebarGeneral,
      sidebarBig:
          lerpDouble(sidebarBig, otherSizes.sidebarBig, t) ?? sidebarBig,
      sidebarHuge:
          lerpDouble(sidebarHuge, otherSizes.sidebarHuge, t) ?? sidebarHuge,
    );
  }
}

/// Sizes extension for [BuildContext].
extension SizesExt on BuildContext {
  /// Returns native bottom insets height.
  double get bottomViewInsets => MediaQuery.viewInsetsOf(this).bottom;
}
