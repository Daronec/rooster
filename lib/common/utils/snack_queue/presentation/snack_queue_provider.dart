import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_controller.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_widget.dart';

/// {@template snack_queue_provider.class}
/// Provides [SnackQueueController] to its descendants.
/// {@endtemplate}
class SnackQueueProvider extends StatelessWidget {
  /// {@macro snack_queue_provider.class}
  const SnackQueueProvider({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Get the [SnackQueueController] from the [BuildContext].
  static SnackQueueController of(BuildContext context) =>
      Provider.of<SnackQueueController>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return SnackQueueWidget(child: child);
  }
}
