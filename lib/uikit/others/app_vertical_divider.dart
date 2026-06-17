import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// {@template app_vertical_divider.class}
/// Renders vertical divider based on [VerticalDivider].
/// {@endtemplate}
class AppVerticalDivider extends StatelessWidget {
  /// {@macro app_vertical_divider.class}
  const AppVerticalDivider({
    super.key,
    this.endIndent = 0.0,
    this.indent = 0.0,
    this.color,
    this.width,
  });

  /// Height for [Divider].
  final double? width;

  /// End indent for [Divider].
  final double? endIndent;

  /// Indent for [Divider].
  final double? indent;

  /// Custom color of divider, which should be used instead of `gray`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final sizesScheme = context.appSizesScheme;
    final colorScheme = context.appColorScheme;

    return VerticalDivider(
      width: width ?? sizesScheme.separatorMicroscopic,
      thickness: sizesScheme.separatorMicroscopic,
      indent: indent,
      endIndent: endIndent,
      color: colorScheme.gray,
    );
  }
}
