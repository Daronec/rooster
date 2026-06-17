import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// {@template settings_tab.class}
/// SettingsTab.
/// {@endtemplate}
class AppTab extends StatelessWidget {
  /// {@macro settings_tab.class}
  const AppTab({
    required this.isActive, required this.width, required this.label, required this.onTap, super.key,
    this.height = AppSizes.double32,
  });

  /// Текущее состояние.
  final bool isActive;

  /// Высота
  final double height;

  /// Ширина таба
  final double width;

  /// Название таба
  final String label;

  /// Обработчик нажатия на таб
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isActive ? colorScheme.black : colorScheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2),
          side: BorderSide(
            color: colorScheme.gray300,
            width: isActive ? AppSizes.double0 : AppSizes.double1,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSizes.borderRadius12,
          child: Center(
            child: Text(
              label,
              style: textScheme.t12Bold.copyWith(
                fontSize: context.isDesktop
                    ? AppSizes.double16
                    : AppSizes.double12,
                color: isActive ? colorScheme.white : colorScheme.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
