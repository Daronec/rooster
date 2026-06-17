import 'package:flutter/material.dart';

/// {@template height.dart}
/// Layout helper for creating vertical inset inside [Column] and similar widgets.
/// {@endtemplate}
class Height extends StatelessWidget {
  /// {@macro height.dart}
  const Height(this.height, {super.key});

  /// Height of inset.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
