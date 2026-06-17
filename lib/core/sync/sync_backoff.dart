import 'dart:math' as math;

/// Экспоненциальный backoff с джиттером для ретраев синхронизации.
final class SyncBackoff {
  /// Базовая задержка.
  SyncBackoff({
    this.base = const Duration(seconds: 2),
    this.max = const Duration(minutes: 5),
    this.multiplier = 2,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Начальная задержка перед первой повторной попыткой.
  final Duration base;

  /// Верхняя граница задержки между попытками.
  final Duration max;

  /// Множитель экспоненты к номеру попытки.
  final double multiplier;
  final math.Random _random;

  /// Задержка перед попыткой номер [attempt] (1-based).
  Duration delayForAttempt(int attempt) {
    final exp =
        math.pow(multiplier, math.max(0, attempt - 1)).toDouble();
    final rawMs = (base.inMilliseconds * exp).round();
    final capped = math.min(rawMs, max.inMilliseconds);
    final jitter = _random.nextDouble() * 0.25 * capped;
    return Duration(milliseconds: (capped + jitter).round());
  }
}
