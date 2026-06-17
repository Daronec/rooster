import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// {@template app_progress_bar.class}
/// AppProgressBar.
/// {@endtemplate}
class AppProgressBar extends StatelessWidget {
  /// {@macro app_progress_bar.class}
  const AppProgressBar({
    required this.maximum,
    required this.progress,
    super.key,
  });

  /// Default progress bar width.
  static const double defaultProgressWidth = 96;

  /// Default progress bar height.
  static const double defaultProgressHeight = 4;

  /// Maximum value of progress.
  final double maximum;

  /// Current progress value.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress / maximum;

    return Container(
      decoration: BoxDecoration(
        color: context.appColorScheme.gray,
        borderRadius: context.appSizesScheme.borderRadiusGeneral,
      ),
      width: defaultProgressWidth,
      height: defaultProgressHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          decoration: BoxDecoration(
            color: context.appColorScheme.red,
            borderRadius: context.appSizesScheme.borderRadiusGeneral,
          ),
          width: defaultProgressWidth * progressPercent,
          height: defaultProgressHeight,
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
