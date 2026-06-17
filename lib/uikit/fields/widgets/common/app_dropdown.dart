import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rooster/gen/resources/resources.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/app_text_field_height.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart' show AppTextField;
import 'package:rooster/uikit/images/vector_image_widget.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Элемент списка для [AppDropdown]: значение и подпись в выпадающем меню.
final class AppDropdownEntity {
  /// Создаёт вариант.
  const AppDropdownEntity({required this.id, required this.label});

  /// Идентификатор выбранного значения.
  final String id;

  /// Текст пункта в списке.
  final String label;
}

/// Подпись сверху и выпадающий список [DropdownButtonFormField2] по [options].
///
/// Высота и скругление строки выбора совпадают с однострочным [AppTextField]
/// при том же [fieldHeight]: на десктопном макете — [AppSizes.double64] и
/// скругление 32; на мобильном — 40/48 px и скругление 12/16 в зависимости от
/// [AppTextFieldHeight]. [outlineBorderRadius] переопределяет скругление, как у
/// [AppTextField.outlineBorderRadius].
///
/// Если [options] пуст: при [allowEmptyOptionsDropdown] == false показывается
/// [emptyMessage] без выпадающего списка; при true — список только с пунктом
/// сброса ([placeholder]).
class AppDropdown extends StatelessWidget {
  /// Создаёт строку выбора.
  const AppDropdown({
    required this.label, required this.emptyMessage, required this.placeholder, required this.valueListenable, required this.options, required this.onChanged, super.key,
    this.allowEmptyOptionsDropdown = false,
    this.fieldHeight = AppTextFieldHeight.compact,
    this.outlineBorderRadius,
  });

  /// Подпись над полем.
  final String label;

  /// Текст при пустом [options], если выпадающий список не показывается.
  final String emptyMessage;

  /// Плейсхолдер и пункт сброса (value `null`).
  final String placeholder;

  /// Текущий выбранный id.
  final ValueListenable<String?> valueListenable;

  /// Доступные варианты.
  final List<AppDropdownEntity> options;

  /// Смена выбора.
  final ValueChanged<String?> onChanged;

  /// Показывать выпадающий список с одним пунктом сброса при пустом [options].
  final bool allowEmptyOptionsDropdown;

  /// Высота строки выбора; должна совпадать с [AppTextField.fieldHeight] в той же форме.
  final AppTextFieldHeight fieldHeight;

  /// Скругление поля и выпадающего меню; если `null` — как у [AppTextField]
  /// с тем же [fieldHeight].
  final BorderRadius? outlineBorderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    final resolvedHeight = fieldHeight.resolveForLayout(context);
    final fieldBorderRadius =
        outlineBorderRadius ?? fieldHeight.borderRadiusForLayout(context);
    final verticalContentPadding = (resolvedHeight - AppSizes.double20) / 2;
    final labelStyle = textScheme.body.t12.copyWith(
      color: colorScheme.gray900,
      fontWeight: FontWeight.w300,
    );
    final textStyle = textScheme.body.t14.copyWith(
      color: colorScheme.gray900,
      fontWeight: FontWeight.w300,
      height: 1,
    );
    final showEmptyState = options.isEmpty && !allowEmptyOptionsDropdown;
    if (showEmptyState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const Height(AppSizes.double8),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: resolvedHeight,
              maxHeight: resolvedHeight,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.double8,
              vertical: verticalContentPadding,
            ),
            decoration: BoxDecoration(
              color: colorScheme.gray200,
              borderRadius: fieldBorderRadius,
              border: Border.all(color: colorScheme.gray300),
            ),
            alignment: Alignment.centerLeft,
            child: Text(emptyMessage, style: textStyle),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const Height(AppSizes.double8),
        ValueListenableBuilder<String?>(
          valueListenable: valueListenable,
          builder: (context, selected, _) {
            final ids = options.map((e) => e.id).toSet();
            final orphan =
                selected != null &&
                selected.isNotEmpty &&
                !ids.contains(selected);
            final items = <DropdownItem<String?>>[
              DropdownItem<String?>(
                child: Text(placeholder, style: textStyle),
              ),
              if (orphan)
                DropdownItem<String?>(
                  value: selected,
                  child: Text(
                    selected,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
              ...options.map(
                (o) => DropdownItem<String?>(
                  value: o.id,
                  child: Text(
                    o.label,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
              ),
            ];
            final fieldBorder = OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.gray300),
              borderRadius: fieldBorderRadius,
              gapPadding: 0,
            );
            final hasSelectedValue = selected != null && selected.isNotEmpty;
            final fieldFillColor = hasSelectedValue
                ? colorScheme.white
                : colorScheme.gray100;
            return DropdownButtonFormField2<String?>(
              valueListenable: valueListenable,
              isExpanded: true,
              decoration: InputDecoration(
                labelStyle: textStyle,
                errorStyle: textStyle,
                floatingLabelStyle: textStyle,
                helperStyle: textStyle,
                hintStyle: textStyle,
                hintText: placeholder,
                border: fieldBorder,
                enabledBorder: fieldBorder,
                focusedBorder: fieldBorder,
                isDense: true,
                filled: true,
                fillColor: fieldFillColor,
                focusColor: fieldFillColor,
                hoverColor: fieldFillColor,
                contentPadding: EdgeInsetsDirectional.only(
                  start: AppSizes.double8,
                  end: AppSizes.double8,
                  top: verticalContentPadding,
                  bottom: verticalContentPadding,
                ),
                constraints: BoxConstraints(
                  maxHeight: resolvedHeight,
                  minHeight: resolvedHeight,
                ),
              ),
              buttonStyleData: FormFieldButtonStyleData(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: fieldFillColor,
                  borderRadius: fieldBorderRadius,
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                useDecorationHorizontalPadding: true,
              ),
              iconStyleData: IconStyleData(
                icon: VectorImageWidget(
                  asset: AssetsIcons.down,
                  width: AppSizes.double16,
                  height: AppSizes.double16,
                  color: colorScheme.gray900,
                ),
                iconSize: AppSizes.double16,
                iconEnabledColor: colorScheme.gray900,
                iconDisabledColor: colorScheme.gray500,
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(borderRadius: fieldBorderRadius),
              ),
              items: items,
              onChanged: onChanged,
            );
          },
        ),
      ],
    );
  }
}
