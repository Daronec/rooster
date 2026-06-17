import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// {@template app_tooltip_widget.dart}
/// App tooltip info widget, provides additional info to the user.
///
/// Wraps [child] with [Tooltip] widget.
/// {@endtemplate}
class AppTooltipWidget extends StatelessWidget {
  /// {@macro app_tooltip_widget.dart}
  const AppTooltipWidget({
    required this.message,
    required this.child,
    this.showDuration = const Duration(seconds: 10),
    super.key,
  });

  /// The text to display in the tooltip.
  final String message;

  /// Tooltip trigger widget.
  final Widget child;

  /// Tooltip show duration.
  final Duration showDuration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;
    final sizesScheme = context.appSizesScheme;
    final textScheme = context.appTextScheme;

    return Tooltip(
      /// We have to use `richMessage` instead of `message` in order to provide width constraints for the tooltip.
      richMessage: TextSpan(
        children: [
          WidgetSpan(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.double256),
              child: Text(
                message,
                style: textScheme.t14.copyWith(color: colorScheme.black),
              ),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.all(sizesScheme.paddingGeneral),
      preferBelow: true,
      decoration: BoxDecoration(
        color: colorScheme.gray,
        borderRadius: sizesScheme.borderRadiusGeneral,
      ),
      showDuration: showDuration,
      exitDuration: showDuration,
      triggerMode: TooltipTriggerMode.tap,
      enableFeedback: false,
      child: child,
    );
  }
}
