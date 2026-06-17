import 'package:flutter/material.dart';

/// {@template width.dart}
/// Layout helper for creating horizontal inset inside [Row] and similar widgets.
/// {@endtemplate}
class Width extends StatelessWidget {
  /// {@macro width.dart}
  const Width(this.width, {super.key});

  /// Width of inset.
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
