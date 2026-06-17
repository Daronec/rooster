import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';

/// Сведения об устройстве для ветки Huawei (без SDK HMS в domain).
abstract interface class IHuaweiDeviceProfileGateway {
  /// Загружает профиль (на не-Android — константы без I/O).
  Future<HuaweiHmsHostProfile> loadProfile();
}
