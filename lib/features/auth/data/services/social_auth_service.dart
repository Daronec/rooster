import 'package:rooster/features/auth/data/services/social_auth_service_types.dart';
import 'package:rooster/features/auth/data/services/social_sign_in_service.dart';

/// Facade that aggregates VK ID and Yandex ID sign-in services.
final class SocialAuthService {
  SocialAuthService({
    required this.vkIdService,
    required this.yandexIdService,
  });

  final SocialSignInService vkIdService;
  final SocialSignInService yandexIdService;

  Future<SocialAuthResult> signInWithVkId() => vkIdService.signIn();
  Future<SocialAuthResult> signInWithYandexId() => yandexIdService.signIn();
}
