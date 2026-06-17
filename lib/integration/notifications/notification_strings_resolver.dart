import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';

/// Минимальный резолвер строк из JSON локализаций (`assets/flutter_i18n/*.json`)
/// без [BuildContext] — нужен для локальных уведомлений.
final class NotificationStringsResolver {
  NotificationStringsResolver._();

  static final Map<String, Map<String, Object?>> _cache =
      <String, Map<String, Object?>>{};

  /// Перевод строки из JSON-локализации по ключу вида `a.b.c`.
  ///
  /// Работает без [BuildContext] и предназначен для локальных уведомлений.
  static Future<String> translate(
    String key, {
    Map<String, String> params = const <String, String>{},
  }) async {
    final lang = PlatformDispatcher.instance.locale.languageCode.trim();
    final map = await _loadLangMap(lang.isEmpty ? 'ru' : lang);
    final raw = _readByDottedKey(map, key) ?? key;
    var result = raw is String ? raw : raw.toString();
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  static Future<Map<String, Object?>> _loadLangMap(String lang) async {
    final normalized = (lang == 'ru' || lang == 'en') ? lang : 'ru';
    final cached = _cache[normalized];
    if (cached != null) {
      return cached;
    }
    final jsonString =
        await rootBundle.loadString('assets/flutter_i18n/$normalized.json');
    final decoded = json.decode(jsonString);
    final map = decoded is Map
        ? decoded.cast<String, Object?>()
        : <String, Object?>{};
    _cache[normalized] = map;
    return map;
  }

  static Object? _readByDottedKey(Map<String, Object?> map, String key) {
    final parts = key.split('.');
    Object? current = map;
    for (final part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}

// end


