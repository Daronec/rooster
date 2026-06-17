import 'package:flutter/material.dart';

import 'package:rooster/uikit/buttons/pushable_button/animation_controller_state.dart';

/// A widget to show a "3D" pushable button
class PushableButton extends StatefulWidget {
  ///
  const PushableButton({
    required this.hslColor, required this.height, super.key,
    this.child,
    this.elevation = 8.0,
    this.shadow,
    this.onPressed,
  }) : assert(height > 0);

  /// child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// height of the top layer
  final double height;

  /// elevation or "gap" between the top and bottom layer
  final double elevation;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;

  /// button pressed callback
  final VoidCallback? onPressed;

  @override
  _PushableButtonState createState() =>
      _PushableButtonState(const Duration(milliseconds: 120));
}

class _PushableButtonState extends AnimationControllerState<PushableButton> {
  _PushableButtonState(super.duration);

  Future<void> _handleTap() async {
    widget.onPressed?.call();

    if (animationController.isAnimating) return;

    await animationController.forward();
    await animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.height + widget.elevation;
    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final top = animationController.value * widget.elevation;
                final hslColor = widget.hslColor;
                final bottomHslColor = hslColor.withLightness(
                  hslColor.lightness - 0.15,
                );
                return Stack(
                  children: [
                    // Draw bottom layer first
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: totalHeight - top,
                        decoration: BoxDecoration(
                          color: bottomHslColor.toColor(),
                          boxShadow: widget.shadow != null
                              ? [widget.shadow!]
                              : [],
                          borderRadius: BorderRadius.circular(
                            widget.height / 2,
                          ),
                        ),
                      ),
                    ),
                    // Then top (pushable) layer
                    Positioned(
                      left: 0,
                      right: 0,
                      top: top,
                      child: Container(
                        height: widget.height,
                        decoration: ShapeDecoration(
                          color: hslColor.toColor(),
                          shape: const StadiumBorder(),
                        ),
                        child: Center(child: widget.child),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
