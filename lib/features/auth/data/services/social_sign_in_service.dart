import 'package:rooster/features/auth/data/services/social_auth_service_types.dart';

/// Abstract service for social sign-in flows.
///
/// Implementations launch the OAuth flow and return a [SocialAuthResult].
abstract class SocialSignInService {
  SocialAuthProvider get provider;
  Future<SocialAuthResult> signIn();
}
