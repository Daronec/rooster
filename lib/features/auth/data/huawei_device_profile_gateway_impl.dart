import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/gateways/i_huawei_device_profile_gateway.dart';

/// [IHuaweiDeviceProfileGateway] на основе [DeviceInfoPlugin] (Android).
final class HuaweiDeviceProfileGatewayImpl implements IHuaweiDeviceProfileGateway {
  /// Создаёт шлюз.
  HuaweiDeviceProfileGatewayImpl({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  @override
  Future<HuaweiHmsHostProfile> loadProfile() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const HuaweiHmsHostProfile(
        isAndroidHost: false,
        isLikelyHuaweiOrHonorDevice: false,
      );
    }
    final android = await _deviceInfo.androidInfo;
    final manufacturer = android.manufacturer.toLowerCase();
    final brand = android.brand.toLowerCase();
    final model = android.model.toLowerCase();
    final isHuaweiFamily = manufacturer.contains('huawei') ||
        manufacturer.contains('honor') ||
        brand.contains('huawei') ||
        brand.contains('honor') ||
        model.contains('huawei');
    return HuaweiHmsHostProfile(
      isAndroidHost: true,
      isLikelyHuaweiOrHonorDevice: isHuaweiFamily,
    );
  }
}
