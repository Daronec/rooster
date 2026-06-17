import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// {@template app_bar_title_widget.class}
/// Title widget that can be used in a screen appbar.
///
/// Renders [title].
/// Can render optional [subtitle].
/// {@endtemplate}
class AppBarTitleWidget extends StatelessWidget {
  /// {@macro app_bar_title_widget.class}
  const AppBarTitleWidget({
    required this.title,
    this.subtitle,
    super.key,
    this.titleWidthLimiter = true,
  });

  /// Title.
  final String title;

  /// Subtitle.
  final String? subtitle;

  /// Title width limiter
  final bool titleWidthLimiter;
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;
    final textScheme = context.appTextScheme;
    final displayedSubtitle = subtitle;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: titleWidthLimiter
            ? MediaQuery.of(context).size.width * 0.6
            : double.infinity,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textScheme.t16Medium.copyWith(color: colorScheme.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (displayedSubtitle != null)
            Text(
              displayedSubtitle,
              style: textScheme.t12.copyWith(color: colorScheme.gray),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
  }
}
