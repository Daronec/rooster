import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/api/data/device_information_dto.dart';
import 'package:rooster/core/domain/entities/device_information/client_type.dart';
import 'package:rooster/core/domain/entities/device_information/device_type.dart';

/// {@macro device_information_service}
class DeviceInformationService implements IDeviceInformationService {

  /// {@macro device_information_service}
  const DeviceInformationService(this._deviceInfo);
  final DeviceInfoPlugin _deviceInfo;

  @override
  Future<DeviceInformationDto?> getDeviceInformation() async {
    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;

      return DeviceInformationDto(device: webInfo.browserName.name);
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;

      return DeviceInformationDto(
        device: androidInfo.model,
        os: DeviceType.android.key,
        osVersion: androidInfo.version.release,
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;

      return DeviceInformationDto(
        device: iosInfo.name,
        os: DeviceType.ios.key,
        osVersion: iosInfo.systemVersion,
      );
    }

    return null;
  }

  @override
  ClientType getClientType() => kIsWeb ? ClientType.web : ClientType.app;

  @override
  Future<AndroidDeviceInfo?> getAndroidInfo() {
    if (Platform.isAndroid) return _deviceInfo.androidInfo;

    return Future.value();
  }
}

/// {@template device_information_service}
/// Service to get device information.
///
/// Used to get information about the device for the server to collect.
///

/// {@endtemplate}
abstract interface class IDeviceInformationService {
  /// Requests android device information. Returns null if current device is not an android.
  Future<AndroidDeviceInfo?> getAndroidInfo();

  /// Collects information about the device.
  ///
  /// The data is collected using the [DeviceInfoPlugin].
  ///
  /// If the client is web, only the browser name is collected.
  ///
  /// If the client is mobile, the device model, OS name, and OS version are collected.
  Future<DeviceInformationDto?> getDeviceInformation();

  /// Returns the type of the device.
  ClientType getClientType();
}

/// Constants for device information storage keys.
enum DeviceInformationStorageKeys {
  /// Key for the web UDID.
  ///
  /// Used to store the web UDID in the local storage.
  ///
  /// Generated from udid plugin.
  webUdid('web_udid');

  /// Key of the storage key.
  final String key;

  const DeviceInformationStorageKeys(this.key);
}
