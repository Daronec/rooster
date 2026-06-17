import 'package:flutter/material.dart';
import 'package:rooster/uikit/buttons/app_button_configurations.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';

/// {@template app_base_button}
/// Базовый виджет для кнопки приложения.
/// {@endtemplate}
class AppBaseButton extends StatefulWidget {
  /// {@macro app_base_button}
  const AppBaseButton({
    required this.state,
    required this.onPressed,
    required this.child,
    required this.style,
    this.subtitle,
    this.subtitleStyle,
    super.key,
  });

  /// Состояние кнопки
  ///
  /// При состоянии, отличном от [ButtonState.active], не работает [onPressed].
  final ButtonState state;

  /// Колбек нажатия на кнопку.
  final VoidCallback? onPressed;

  /// Основной контент кнопки (заголовок).
  final Widget child;

  /// Дополнительная строка под заголовком; при null — однострочная кнопка как раньше.
  final Widget? subtitle;

  /// Стиль подзаголовка; по умолчанию — уменьшенный [DefaultTextStyle] кнопки (тот же цвет).
  final TextStyle? subtitleStyle;

  /// Стиль кнопки.
  final ButtonStyle style;

  @override
  State<AppBaseButton> createState() => _AppBaseButtonState();
}

class _AppBaseButtonState extends State<AppBaseButton> {
  late final WidgetStatesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WidgetStatesController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.state == ButtonState.loading;
    final isInactive = widget.state == ButtonState.disabled;

    final buttonLabel = Builder(
      builder: (context) {
        final base = DefaultTextStyle.of(context).style;
        final resolvedSubtitleStyle =
            widget.subtitleStyle ??
            base.copyWith(
              fontSize: base.fontSize ?? 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
            );

        final title = DefaultTextStyle.merge(
          softWrap: false,
          maxLines: 1,
          child: widget.child,
        );

        if (widget.subtitle == null) {
          return title;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            title,
            DefaultTextStyle.merge(
              style: resolvedSubtitleStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              child: widget.subtitle!,
            ),
          ],
        );
      },
    );

    return SelectionContainer.disabled(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          TextButton(
            onPressed: switch ((isInactive, isLoading)) {
              (false, false) => widget.onPressed,
              // ignore: no-empty-block
              (false, true) => () {},
              _ => null,
            },
            style: widget.style,
            statesController: _controller,
            child: DefaultTextStyle.merge(
              child: Offstage(offstage: isLoading, child: buttonLabel),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: isLoading
                  ? Center(
                      child: ValueListenableBuilder<Set<WidgetState>>(
                        valueListenable: _controller,
                        builder: (_, states, _) {
                          return RepaintBoundary(
                            child: SizedBox(
                              width: context.appSizesScheme.loaderSizeMaximum,
                              height: context.appSizesScheme.loaderSizeMaximum,
                              child: CircularProgressIndicator(
                                color: widget.style.foregroundColor?.resolve(
                                  states,
                                ),
                                strokeWidth:
                                    context.appSizesScheme.strokeGeneral,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
