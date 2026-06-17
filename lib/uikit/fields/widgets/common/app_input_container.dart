import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// App input container.
///
/// Container for containing widgets in input-like wrapper.
class AppInputContainer extends StatelessWidget {
  /// Meeting container constructor.
  const AppInputContainer({required this.child, this.padding, super.key});

  /// Child widget.
  final Widget child;

  /// Внутренний отступ.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: colorScheme.white,
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.double16),
          smoothness: 1,
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
