/// Доступность Google Play services для клиентских SDK Firebase на Android.
abstract interface class IGooglePlayServicesStatusGateway {
  /// На **не-Android** всегда `true` (флаг не участвует в выборе стратегии).
  ///
  /// На Android: `true` только если GMS в рабочем состоянии для приложения.
  Future<bool> areUsableForFirebaseClients();
}
