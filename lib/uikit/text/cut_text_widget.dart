import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Widget that cuts [text] by [maxLines] and displays button to navigate to full view.
class CutTextWidget extends StatelessWidget {
  /// Widget that cuts [text] by [maxLines] and displays button to navigate to full view.
  const CutTextWidget({
    required this.text,
    required this.maxLines,
    this.buttonTitle,
    this.onTap,
    this.style,
    super.key,
  });

  /// Text to be cut by maxLines.
  final String text;

  /// Button title.
  final String? buttonTitle;

  /// Text style.
  final TextStyle? style;

  /// Max lines.
  final int maxLines;

  /// On expand tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? context.appTextScheme.t16;

    final buttonTitle = this.buttonTitle;

    return SelectionArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Width(double.infinity),
          Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
          if (buttonTitle != null)
            InkWell(
              onTap: onTap,
              child: Text(
                buttonTitle,
                style: textStyle.copyWith(color: context.appColorScheme.red),
              ),
            ),
        ],
      ),
    );
  }
}
