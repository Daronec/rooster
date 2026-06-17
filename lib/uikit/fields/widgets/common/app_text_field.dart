import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/app_text_field_height.dart';
import 'package:rooster/uikit/fields/input_decoration_outline_radius.dart';
import 'package:rooster/uikit/fields/validators/field_validator.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Поле для ввода текста.
///
/// Скругление рамки: [outlineBorderRadius] или правило [fieldHeight] + макет.
class AppTextField extends StatefulWidget {
  /// Создать экземпляр [AppTextField].
  const AppTextField({
    this.fieldKey,
    this.decoration,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.addClearButton = false,
    this.enabled = true,
    this.saveFocusOnOutsideTap = false,
    this.enableInteractiveSelection = true,
    this.obscureText = false,
    this.actions = const [],
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.capitalizeFirst = false,
    this.validateOnLostFocusIfInteracted = false,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.autoFillHints,
    this.initialValue,
    this.maxLength,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.hintText,
    super.key,
    this.scrollPadding,
    this.fieldHeight = AppTextFieldHeight.compact,
    this.outlineBorderRadius,
  }) : assert(minLines == null || minLines > 0),
       assert(maxLines == null || maxLines > 0),
       assert(
         (minLines == null) || (maxLines == null) || (maxLines >= minLines),
         "minLines can't be greater than maxLines",
       ),
       assert(
         !validateOnLostFocusIfInteracted ||
             validateOnLostFocusIfInteracted && fieldKey != null,
         'fieldKey is required for on lost focus validation',
       );

  /// Компактное поле: при [fieldHeight] по умолчанию [AppTextFieldHeight.compact]
  /// высота [AppSizes.double40] на мобильном и [AppSizes.double64] на десктопе;
  /// скругление — [outlineBorderRadius] или [AppTextFieldHeight.borderRadiusForLayout]
  /// (моб. 12 / 16, десктоп 32).
  /// Фон белый, пока поле пустое, и
  /// [AppColorScheme.gray100], когда введён текст.
  ///
  /// Оформление задаётся через [filledCompactDecoration]; при необходимости
  /// расширьте его вызовом [InputDecoration.copyWith].
  factory AppTextField.filledCompact(
    BuildContext context, {
    Key? key,
    String? labelText,
    String? hintText,
    GlobalKey<FormFieldState<String>>? fieldKey,
    ValueChanged<String>? onChanged,
    TextEditingController? controller,
    FocusNode? focusNode,
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool addClearButton = false,
    bool enabled = true,
    bool saveFocusOnOutsideTap = false,
    bool enableInteractiveSelection = true,
    bool obscureText = false,
    List<Widget> actions = const [],
    FieldValidator<String>? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool capitalizeFirst = false,
    bool validateOnLostFocusIfInteracted = false,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    List<String>? autoFillHints,
    String? initialValue,
    int? maxLength,
    bool autofocus = false,
    TextAlign textAlign = TextAlign.start,
    EdgeInsets? scrollPadding,
    AppTextFieldHeight fieldHeight = AppTextFieldHeight.compact,
    BorderRadius? outlineBorderRadius,
  }) {
    assert(minLines == null || minLines > 0);
    assert(maxLines == null || maxLines > 0);
    assert(
      (minLines == null) || (maxLines == null) || (maxLines >= minLines),
      "minLines can't be greater than maxLines",
    );
    assert(
      !validateOnLostFocusIfInteracted ||
          validateOnLostFocusIfInteracted && fieldKey != null,
      'fieldKey is required for on lost focus validation',
    );
    return AppTextField(
      key: key,
      fieldKey: fieldKey,
      fieldHeight: fieldHeight,
      outlineBorderRadius: outlineBorderRadius,
      decoration: filledCompactDecoration(
        context,
        labelText: labelText,
        hintText: hintText,
      ),
      onChanged: onChanged,
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      addClearButton: addClearButton,
      enabled: enabled,
      saveFocusOnOutsideTap: saveFocusOnOutsideTap,
      enableInteractiveSelection: enableInteractiveSelection,
      obscureText: obscureText,
      actions: actions,
      validator: validator,
      textCapitalization: textCapitalization,
      capitalizeFirst: capitalizeFirst,
      validateOnLostFocusIfInteracted: validateOnLostFocusIfInteracted,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      autoFillHints: autoFillHints,
      initialValue: initialValue,
      maxLength: maxLength,
      autofocus: autofocus,
      textAlign: textAlign,
      scrollPadding: scrollPadding,
    );
  }

  /// [InputDecoration] для [AppTextField.filledCompact]: рамка [AppColorScheme.gray300].
  ///
  /// Фиксированная высота и вертикальные отступы задаются в [AppTextField] через
  /// [fieldHeight] и ширину макета (на десктопе — [AppSizes.double64]).
  ///
  /// [fillColor] в шаблоне задаёт начальное значение; в [AppTextField] для
  /// `filled == true` фон пересчитывается: пустой ввод — белый, непустой — [AppColorScheme.gray100].
  static InputDecoration filledCompactDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
  }) {
    final textScheme = context.appTextScheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      isDense: true,
      labelStyle: textScheme.t14,
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Global key to access [FormFieldState].
  final GlobalKey<FormFieldState<String>>? fieldKey;

  /// If need to validate field on lost focus after user interaction.
  // ignore: prefer-correct-identifier-length
  final bool validateOnLostFocusIfInteracted;

  /// [TextEditingController].
  final TextEditingController? controller;

  /// Initial text field value.
  final String? initialValue;

  /// Padding for input when focused.
  final EdgeInsets? scrollPadding;

  /// Включить интерактивное выделение текста.
  final bool enableInteractiveSelection;

  /// [FocusNode].
  final FocusNode? focusNode;

  /// Сохранять фокус при тапе вне поля.
  final bool saveFocusOnOutsideTap;

  /// Колбек изменения значения в поле.
  final ValueChanged<String>? onChanged;

  /// Autofill hints.
  final List<String>? autoFillHints;

  /// Включено ли поле.
  final bool enabled;

  /// Максимальное число линий текста.
  final int? maxLines;

  /// Минимальное число линий текста.
  final int? minLines;

  /// Maximum amount of length in input.
  final int? maxLength;

  /// Тип вводимых символов.
  final TextInputType? keyboardType;

  /// Добавлять кнопку очистки поля.
  final bool addClearButton;

  /// Нужно ли скрывать текст.
  final bool obscureText;

  /// Форматеры.
  final List<TextInputFormatter>? inputFormatters;

  /// Конфигурация UI для поля ввода.
  final InputDecoration? decoration;

  /// Валидатор поля.
  final FieldValidator<String>? validator;

  /// Набор виджетов, которые помещаются в правую часть поля ввода.
  ///
  /// Например, иконка очистки поля.
  final List<Widget> actions;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Если true, клавиатура предлагает заглавную букву в начале и после конца
  /// предложения ([TextCapitalization.sentences]). Приоритетнее [textCapitalization].
  final bool capitalizeFirst;

  /// Text input action.
  final TextInputAction? textInputAction;

  /// On editing complete action.
  final VoidCallback? onEditingComplete;

  /// Вызывается при отправке с клавиатуры (например, клавиша Enter).
  final ValueChanged<String>? onFieldSubmitted;

  /// Manage keyboard focus.
  final bool autofocus;

  /// Выравнивание текста.
  final TextAlign textAlign;

  ///
  final String? hintText;

  /// Вертикальный размер однострочного поля (на десктопном макете всегда 64 px).
  final AppTextFieldHeight fieldHeight;

  /// Скругление всех [OutlineInputBorder] в [decoration].
  ///
  /// Если `null`, используется [AppTextFieldHeight.borderRadiusForLayout]
  /// для [fieldHeight].
  final BorderRadius? outlineBorderRadius;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  late bool _validatedAfterLostFocus;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(focusListener);
    _controller.addListener(_onControllerTextChanged);
    _validatedAfterLostFocus = false;
  }

  void _onControllerTextChanged() {
    if (!mounted) return;
    final decoration = widget.decoration ?? const InputDecoration();
    if (decoration.filled ?? false) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focus.dispose();
    }
    super.dispose();
  }

  /// Listens focus events for this field.
  /// Runs field validation on lost focus if validateOnLostFocusIfInteracted is true.
  void focusListener() {
    if (!widget.validateOnLostFocusIfInteracted) return;

    if (!_focus.hasFocus) {
      final fieldWasInteracted =
          widget.fieldKey?.currentState?.hasInteractedByUser ?? false;

      if (fieldWasInteracted) {
        widget.fieldKey?.currentState?.validate();

        /// Set _validatedAfterLostFocus flag value to true.
        _validatedAfterLostFocus = true;
      }
    }
  }

  /// Handles change of value of this field.
  /// Runs field validation if _validatedAfterLostFocus is true.
  void handleChanged(String value) {
    /// Validate field value after each update if it have been already validated on lost focus previously.
    if (_validatedAfterLostFocus) {
      widget.fieldKey?.currentState?.validate();
    }

    /// Call on changed callback if present.
    widget.onChanged?.call(value);
  }

  bool get _isSingleLine =>
      (widget.maxLines ?? 1) == 1 &&
      (widget.minLines == null || widget.minLines == 1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.appColorScheme;
    final textScheme = context.appTextScheme;
    final disabled = !widget.enabled;
    final rawDecoration = widget.decoration ?? const InputDecoration();
    final mergedDecoration = rawDecoration.applyDefaults(
      Theme.of(context).inputDecorationTheme,
    );
    final resolvedOutlineBorderRadius =
        widget.outlineBorderRadius ?? AppSizes.borderRadius12;
    final decorationWithRadius = applyOutlineInputBorderRadius(
      mergedDecoration,
      resolvedOutlineBorderRadius,
    );
    final decoration = decorationWithRadius.copyWith(
      filled: true,
      fillColor: colorScheme.white,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );

    final resolvedHeight = _isSingleLine
        ? (() {
            final height = widget.fieldHeight.resolveForLayout(context);
            return height < AppSizes.double48 ? AppSizes.double48 : height;
          })()
        : null;

    return ClipRRect(
      borderRadius: resolvedOutlineBorderRadius,
      child: TextFormField(
        key: widget.fieldKey,
        controller: _controller,
        focusNode: _focus,
        textAlign: widget.textAlign,
        decoration: decoration.copyWith(
          hintText: widget.hintText,
          labelStyle: decoration.labelStyle ?? textScheme.t14,
          hintStyle: decoration.hintStyle ?? textScheme.t14,
          helperStyle: TextStyle(color: colorScheme.gray),
          contentPadding: const EdgeInsets.all(AppSizes.double8),
          constraints: resolvedHeight != null
              ? BoxConstraints(
                  minHeight: resolvedHeight,
                  maxHeight: resolvedHeight,
                )
              : decoration.constraints,
          suffixIcon: widget.addClearButton || widget.actions.isNotEmpty
              ? IconButtonTheme(
                  data: IconButtonThemeData(
                    style: ButtonStyle(
                      iconColor: WidgetStateProperty.all(
                        disabled ? colorScheme.gray : colorScheme.gray,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.addClearButton)
                        _ClearIconButton(controller: _controller),
                      ...widget.actions,
                    ],
                  ),
                )
              : null,
        ),
        keyboardType: widget.keyboardType,
        textCapitalization: widget.capitalizeFirst
            ? TextCapitalization.sentences
            : widget.textCapitalization,
        textInputAction: widget.textInputAction,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onChanged: handleChanged,
        onTapOutside: widget.saveFocusOnOutsideTap
            ? null
            : (_) => _focus.unfocus(),
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator?.validate,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorHeight: AppSizes.double20,
        scrollPadding:
            widget.scrollPadding ??
            EdgeInsets.all(context.appSizesScheme.paddingGeneral),
        enableInteractiveSelection: widget.enableInteractiveSelection,
        buildCounter:
            (
              ctx, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) => const SizedBox(),
        autofillHints: widget.autoFillHints,
      ),
    );
  }
}

class _ClearIconButton extends StatelessWidget {
  const _ClearIconButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();

        return IconButton(
          onPressed: controller.clear,
          icon: Icon(Icons.close, size: context.appSizesScheme.iconSizeHuge),
        );
      },
    );
  }
}
