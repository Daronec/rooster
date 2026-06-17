import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/domain/gateways/i_tasks_screen_expanded_group_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Реализация [ITasksScreenExpandedGroupStorage] через [SharedPreferences].
final class TasksScreenExpandedGroupStorageImpl
    implements ITasksScreenExpandedGroupStorage {
  /// Создаёт хранилище.
  TasksScreenExpandedGroupStorageImpl(this._preferences);

  static const String _keyIds = 'tasks_screen_expanded_list_ids';

  /// Старый ключ с одним id (миграция при чтении).
  static const String _keyLegacy = 'tasks_screen_expanded_list_id';

  final SharedPreferences _preferences;

  @override
  Future<Set<String>> loadExpandedListIds() async {
    final rawIds = _preferences.getString(_keyIds);
    if (rawIds != null && rawIds.isNotEmpty) {
      final decoded = jsonDecode(rawIds);
      if (decoded is List<dynamic>) {
        return decoded
            .map((element) => '$element')
            .where((id) => id.isNotEmpty)
            .toSet();
      }
    }
    final legacy = _preferences.getString(_keyLegacy);
    if (legacy != null && legacy.isNotEmpty) {
      return <String>{legacy};
    }
    return <String>{};
  }

  @override
  Future<void> saveExpandedListIds(Set<String> listIds) async {
    if (listIds.isEmpty) {
      await _preferences.remove(_keyIds);
      await _preferences.remove(_keyLegacy);
    } else {
      final sorted = listIds.toList()..sort();
      await _preferences.setString(_keyIds, jsonEncode(sorted));
      await _preferences.remove(_keyLegacy);
    }
    if (kDebugMode) {
      debugPrint(
        '[TasksScreenExpandedGroupStorage] saved expanded listIds=$listIds',
      );
    }
  }
}
