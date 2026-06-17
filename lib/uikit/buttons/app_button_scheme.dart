import 'package:flutter/material.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/buttons/app_button_style.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_button_scheme.tailor.dart';

/// App button styles.
///
/// This extension is in sync with base [ThemeData] and [AppButtonScheme].
///
/// Use case:
///
/// ```dart
/// final buttonScheme = AppButtonScheme.of(context);
///
/// return
/// ```
@immutable
@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppButtonScheme extends ThemeExtension<AppButtonScheme>
    with _$AppButtonSchemeTailorMixin {

  /// @nodoc.
  const AppButtonScheme({
    required this.primaryLarge,
    required this.primaryMedium,
    required this.primarySmall,
    required this.blackLarge,
    required this.blackMedium,
    required this.blackSmall,
    required this.grayLarge,
    required this.grayMedium,
    required this.graySmall,
  });

  /// @nodoc.
  factory AppButtonScheme.base({
    required AppColorScheme colorScheme,
    required AppTextScheme textScheme,
  }) {
    return AppButtonScheme(
      primaryLarge: AppButtonStyle.primary(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.large,
      ),
      primaryMedium: AppButtonStyle.primary(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.medium,
      ),
      primarySmall: AppButtonStyle.primary(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.small,
      ),
      blackLarge: AppButtonStyle.black(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.large,
      ),
      blackMedium: AppButtonStyle.black(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.medium,
      ),
      blackSmall: AppButtonStyle.black(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.small,
      ),
      grayLarge: AppButtonStyle.gray(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.large,
      ),
      grayMedium: AppButtonStyle.gray(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.medium,
      ),
      graySmall: AppButtonStyle.gray(
        colorScheme: colorScheme,
        textScheme: textScheme,
        size: AppButtonSize.small,
      ),
    );
  }
  @override
  final ButtonStyle primaryLarge;

  @override
  final ButtonStyle primaryMedium;

  @override
  final ButtonStyle primarySmall;

  @override
  final ButtonStyle blackLarge;

  @override
  final ButtonStyle blackMedium;

  @override
  final ButtonStyle blackSmall;

  @override
  final ButtonStyle grayLarge;

  @override
  final ButtonStyle grayMedium;

  @override
  final ButtonStyle graySmall;

  /// @nodoc.
  static AppButtonScheme of(BuildContext context) => context.appButtonScheme;

  @override
  AppButtonScheme lerp(
    covariant ThemeExtension<AppButtonScheme>? other,
    double t,
  ) {
    if (other is! AppButtonScheme) return this;

    return AppButtonScheme(
      primaryLarge:
          ButtonStyle.lerp(primaryLarge, other.primaryLarge, t) ?? primaryLarge,
      primaryMedium:
          ButtonStyle.lerp(primaryMedium, other.primaryMedium, t) ??
          primaryMedium,
      primarySmall:
          ButtonStyle.lerp(primarySmall, other.primarySmall, t) ?? primarySmall,
      blackLarge:
          ButtonStyle.lerp(blackLarge, other.blackLarge, t) ?? blackLarge,
      blackMedium:
          ButtonStyle.lerp(blackMedium, other.blackMedium, t) ?? blackMedium,
      blackSmall:
          ButtonStyle.lerp(blackSmall, other.blackSmall, t) ?? blackSmall,
      grayLarge: ButtonStyle.lerp(grayLarge, other.grayLarge, t) ?? grayLarge,
      grayMedium:
          ButtonStyle.lerp(grayMedium, other.grayMedium, t) ?? grayMedium,
      graySmall: ButtonStyle.lerp(graySmall, other.graySmall, t) ?? graySmall,
    );
  }
}
