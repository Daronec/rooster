/// Результат успешного входа через HUAWEI Account Kit.
final class HuaweiHmsAuthPayloadEntity {
  /// Создаёт сущность.
  const HuaweiHmsAuthPayloadEntity({
    required this.idToken,
    this.unionId,
    this.openId,
    this.accessToken,
  });

  /// ID Token (JWT) для серверной проверки при обмене на сессию Firebase (ветка GMS).
  final String idToken;

  /// UnionID HUAWEI (если запрошен scope).
  final String? unionId;

  /// OpenID HUAWEI (если запрошен scope).
  final String? openId;

  /// Access token OAuth2 (если запрошен).
  final String? accessToken;
}
