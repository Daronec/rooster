import 'package:flutter/foundation.dart';

/// Правила отображения способов входа Appwrite на экране авторизации (платформа и устройство).
abstract final class AppwriteAuthSignInUiPolicy {
  /// Показывать вход через Google (Android без Huawei/Honor, не web).
  static bool offersGoogleSignIn({
    required bool isLikelyHuaweiOrHonorAndroid,
  }) =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !isLikelyHuaweiOrHonorAndroid;

  /// Показывать вход через Apple (iOS, не web).
  static bool offersAppleSignIn() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Показывать форму email и пароль (web, настольные ОС или Huawei/Honor на Android).
  static bool offersEmailPasswordSignIn({
    required bool isLikelyHuaweiOrHonorAndroid,
  }) =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      (!kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android &&
          isLikelyHuaweiOrHonorAndroid);
}
