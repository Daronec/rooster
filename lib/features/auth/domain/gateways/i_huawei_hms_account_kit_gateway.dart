import 'package:rooster/features/auth/domain/entities/huawei_hms_auth_payload_entity.dart';

/// Порт HUAWEI Account Kit (HMS) — только интерактивный вход, без Firebase.
abstract interface class IHuaweiHmsAccountKitGateway {
  /// Поддерживается ли на текущей платформе (ожидается Android с HMS).
  bool get isSupported;

  /// Интерактивный вход; `null` — пользователь отменил или вход невозможен.
  Future<HuaweiHmsAuthPayloadEntity?> signInInteractively();

  /// Выход из HUAWEI ID на устройстве (после сброса облачной сессии приложения при необходимости).
  Future<void> signOutHuawei();
}
