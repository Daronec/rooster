import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// App theme divider.
class AppDivider extends StatelessWidget {
  /// Create instance of [AppDivider].
  const AppDivider({
    super.key,
    this.endIndent,
    this.indent,
    this.color,
    this.height,
  });

  /// Height for [Divider].
  final double? height;

  /// End indent for [Divider].
  final double? endIndent;

  /// Indent for [Divider].
  final double? indent;

  /// Custom color of divider, which should be used instead of `gray`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? context.appSizesScheme.separatorMicroscopic,
      thickness: context.appSizesScheme.separatorMicroscopic,
      indent: indent,
      endIndent: endIndent,
      color: context.appColorScheme.gray,
    );
  }
}
