/// Constants for device information.
///
/// Used to determine, which OS is being used.
enum DeviceType {
  /// Android device.
  android('android', 'Android'),

  /// IOS device.
  ios('ios', 'iOS');

  /// Key of the device type.
  final String key;

  /// Formatted device type.
  final String formatted;

  const DeviceType(this.key, this.formatted);
}
