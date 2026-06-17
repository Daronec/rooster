import 'package:flutter/material.dart';

/// Задаёт одинаковый [BorderRadius] всем [OutlineInputBorder] в [source].
InputDecoration applyOutlineInputBorderRadius(
  InputDecoration source,
  BorderRadius borderRadius,
) {
  InputBorder? mapBorder(InputBorder? border) {
    if (border is OutlineInputBorder) {
      return border.copyWith(borderRadius: borderRadius);
    }
    return border;
  }

  return source.copyWith(
    border: mapBorder(source.border),
    enabledBorder: mapBorder(source.enabledBorder),
    focusedBorder: mapBorder(source.focusedBorder),
    disabledBorder: mapBorder(source.disabledBorder),
    errorBorder: mapBorder(source.errorBorder),
    focusedErrorBorder: mapBorder(source.focusedErrorBorder),
  );
}

/// Задаёт [borderRadius] всем границам [InputDecoration]: [OutlineInputBorder]
/// обновляются через [OutlineInputBorder.copyWith], остальные типы заменяются
/// на outline с тем же [BorderSide] (или [fallbackBorderSide], если линия
/// отсутствует). Нужно там, где после [InputDecoration.applyDefaults] граница
/// может не быть [OutlineInputBorder], из‑за чего [applyOutlineInputBorderRadius]
/// не меняет форму.
InputDecoration applyUniformOutlineInputBorderRadius(
  InputDecoration source,
  BorderRadius borderRadius, {
  required BorderSide fallbackBorderSide,
}) {
  OutlineInputBorder coerce(InputBorder? border) {
    if (border == null) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: fallbackBorderSide,
      );
    }
    if (border is OutlineInputBorder) {
      return border.copyWith(borderRadius: borderRadius);
    }
    final side = border.borderSide;
    return OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: side == BorderSide.none ? fallbackBorderSide : side,
    );
  }

  return source.copyWith(
    border: coerce(source.border),
    enabledBorder: coerce(source.enabledBorder),
    focusedBorder: coerce(source.focusedBorder),
    disabledBorder: coerce(source.disabledBorder),
    errorBorder: coerce(source.errorBorder),
    focusedErrorBorder: coerce(source.focusedErrorBorder),
  );
}
