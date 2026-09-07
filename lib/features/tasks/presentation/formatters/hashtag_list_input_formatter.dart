// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

/// Форматтер ввода списка тегов в виде `#tag1, #tag2, #tag3`.
///
/// Правила:
/// - если ввода нет, показывается `#`;
/// - после пробела или запятой начинается новый тег и добавляется `#`;
/// - повторные разделители нормализуются;
/// - лишние `#` внутри значения убираются.
final class HashtagListInputFormatter extends TextInputFormatter {
  const HashtagListInputFormatter();

  static final RegExp _separator = RegExp('[ ,]+');
  static final RegExp _trailingSeparator = RegExp(r'[ ,]+$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final formatted = _format(raw);

    // Для ввода тегов UX обычно лучше держать каретку в конце —
    // форматтер активно нормализует строку.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String raw) {
    final trimmedLeft = raw.replaceFirst(RegExp('^[ ,]+'), '');
    final endsWithSeparator = _trailingSeparator.hasMatch(raw);
    final parts = trimmedLeft
        .split(_separator)
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment.replaceAll('#', ''))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return '#';
    }

    final base = parts.map((segment) => '#$segment').join(', ');
    if (endsWithSeparator) {
      return '$base, #';
    }
    return base;
  }
}


