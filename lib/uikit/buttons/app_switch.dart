import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// {@template app_switch.dart}
/// App Switch.
/// {@endtemplate}
class AppSwitch extends StatelessWidget {
  /// {@macro app_switch.dart}
  const AppSwitch({required this.value, this.onSwitch, super.key});

  /// Switch state.
  final bool value;

  /// [ValueChanged] for switch.
  final ValueChanged<bool>? onSwitch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;

    final activeTrackColor = colorScheme.green;
    final inactiveTrackColor = colorScheme.gray300;

    return SizedBox(
      height: context.isDesktop ? AppSizes.double40 : AppSizes.double22,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Switch(
          value: value,
          onChanged: onSwitch,
          activeTrackColor: activeTrackColor,
          inactiveTrackColor: inactiveTrackColor,
          thumbColor: WidgetStatePropertyAll(colorScheme.white),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          trackOutlineWidth: WidgetStatePropertyAll(
            context.appSizesScheme.strokeGeneral,
          ),
          thumbIcon: WidgetStateProperty.resolveWith<Icon>(
            (_) => Icon(
              Icons.circle,
              size: context.isDesktop ? AppSizes.double34 : AppSizes.double16,
              color: Colors.white,
            ),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
