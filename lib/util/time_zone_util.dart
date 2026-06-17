/// Utility for mapping GMT+3 (MSK) time to local time.
final class TimeZoneUtil {
  static int get _localTimeZone => DateTime.now().timeZoneOffset.inHours;

  static int get _centralTimeZone => 3;

  static int get _diff => _localTimeZone - _centralTimeZone;

  static Duration get _diffDurtion => Duration(hours: _diff.abs());

  /// Parse backend time from GMT+3 to local time.
  static DateTime parseBackendTime(DateTime time) =>
      _diff > 0 ? time.add(_diffDurtion) : time.subtract(_diffDurtion);

  /// Map local time to GMT+3 time.
  static DateTime toBackendTime(DateTime time) =>
      _diff > 0 ? time.subtract(_diffDurtion) : time.add(_diffDurtion);

  /// Parse backend time from GMT+3 to local time.
  static DateTime? parseNullableBackendTime(DateTime? time) =>
      time == null ? null : parseBackendTime(time);

  /// Map local time to GMT+3 time.
  static DateTime? toNullableBackendTime(DateTime? time) =>
      time == null ? null : toBackendTime(time);
}
