/// Constants for device information.
///
/// Used to determine, which client is being used.
enum ClientType {
  /// Web client.
  ///
  /// Used when the client is a web browser.
  web('web'),

  /// Mobile client.
  ///
  /// Used when the client is a mobile device.
  app('app');

  /// Key of the client type.
  final String key;

  const ClientType(this.key);
}
