import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/uikit/buttons/app_switch.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Строка настроек с переключателем вкл/выкл (свет, розетки и т.п.).
class AppPropertySwitchTile extends StatelessWidget {
  /// Создаёт тайл с заголовком и [AppSwitch].
  const AppPropertySwitchTile({
    required this.name,
    required this.isActive,
    required this.onSwitch,
    this.isAccess = false,
    this.enabled = true,
    this.children = const [],
    super.key,
  });

  /// Заголовок строки.
  final String name;

  /// Текущее состояние «включено».
  final bool isActive;

  /// Доступность переключения (например, контроллер офлайн).
  final bool enabled;

  /// Определяет описание элемента
  final bool isAccess;

  /// Обработчик смены состояния; при [enabled] == false игнорируется.
  final ValueChanged<bool>? onSwitch;

  /// Контент строки.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    final labelColor = enabled ? colorScheme.gray900 : colorScheme.gray400;
    return Container(
      padding: context.isDesktop
          ? const EdgeInsets.symmetric(
              vertical: AppSizes.double16,
              horizontal: AppSizes.double24,
            )
          : const EdgeInsets.symmetric(vertical: AppSizes.double8),
      decoration: BoxDecoration(
        borderRadius: context.isDesktop
            ? BorderRadius.circular(AppSizes.double16)
            : null,
        border: context.isDesktop
            ? Border.all(color: colorScheme.gray200)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: textScheme.body.t20Medium.copyWith(
                    color: labelColor,
                    fontSize: context.isDesktop
                        ? AppSizes.double20
                        : AppSizes.double14,
                  ),
                ),
              ),
              AppSwitch(
                value: isActive,
                onSwitch: enabled ? onSwitch : null,
              ),
            ],
          ),
          if (children.isNotEmpty)
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.double16),
                child: child,
              ),
            ),
        ],
      ),
    );
  }
}
