import 'package:flutter/foundation.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:rooster/features/auth/domain/gateways/i_google_play_services_status_gateway.dart';

/// [IGooglePlayServicesStatusGateway] через [GoogleApiAvailability] (Android).
final class GooglePlayServicesStatusGatewayImpl
    implements IGooglePlayServicesStatusGateway {
  @override
  Future<bool> areUsableForFirebaseClients() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    final status =
        await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
    return status == GooglePlayServicesAvailability.success;
  }
}
