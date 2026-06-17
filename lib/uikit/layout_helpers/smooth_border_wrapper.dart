import 'package:flutter/material.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// Карточка с гладкой обводкой [SmoothRectangleBorder].
class SmoothBorderWrapper extends StatelessWidget {
  /// Создаёт оболочку.
  const SmoothBorderWrapper({
    required this.child, required this.padding, super.key,
    this.backgroundColor,
  });

  /// Содержимое.
  final Widget child;

  /// Внутренние отступы.
  final EdgeInsets? padding;

  /// Цвет фона.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.double24),
      decoration: ShapeDecoration(
        color: backgroundColor ?? colorScheme.white,
        shape: SmoothRectangleBorder(
          side: BorderSide(color: colorScheme.gray300),
          borderRadius: BorderRadius.circular(AppSizes.double24),
          smoothness: 1,
        ),
      ),
      child: child,
    );
  }
}
