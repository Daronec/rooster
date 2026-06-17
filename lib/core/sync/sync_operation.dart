import 'package:rooster/core/sync/sync_operation_type.dart';

/// Единица работы синхронизации: тип, полезная нагрузка и метаданные ретрая.
final class SyncOperation {
  /// Создаёт операцию.
  const SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    this.attemptCount = 0,
    this.lastError,
    this.createdAtMillis,
  });

  /// Восстановление из Hive/map.
  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as String,
      type: SyncOperationType.values.byName(map['type'] as String),
      payload: Map<String, Object?>.from(
        (map['payload'] as Map?)?.cast<String, Object?>() ?? {},
      ),
      attemptCount: (map['attemptCount'] as num?)?.toInt() ?? 0,
      lastError: map['lastError'] as String?,
      createdAtMillis: (map['createdAtMillis'] as num?)?.toInt(),
    );
  }

  /// Стабильный id операции в очереди (UUID v4).
  final String id;

  /// Тип операции.
  final SyncOperationType type;

  /// Сериализуемые данные (ids сущностей, карты полей).
  final Map<String, Object?> payload;

  /// Число попыток отправки.
  final int attemptCount;

  /// Текст последней ошибки (для dev-панели).
  final String? lastError;

  /// Время постановки в очередь (epoch ms).
  final int? createdAtMillis;

  /// Копия с изменёнными полями ретрая.
  SyncOperation copyWith({
    int? attemptCount,
    String? lastError,
  }) {
    return SyncOperation(
      id: id,
      type: type,
      payload: payload,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      createdAtMillis: createdAtMillis,
    );
  }

  /// Сериализация для Hive.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'attemptCount': attemptCount,
      if (lastError != null) 'lastError': lastError,
      if (createdAtMillis != null) 'createdAtMillis': createdAtMillis,
    };
  }
}
