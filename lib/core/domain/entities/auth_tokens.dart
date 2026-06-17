import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';

/// {@template AuthTokens.class}
/// Токены для авторизации.
/// {@endtemplate}
@freezed
@immutable
abstract class AuthTokens with _$AuthTokens {
  /// {@macro AuthTokens.class}
  const factory AuthTokens({
    /// Access token.
    required String accessToken,

    /// Refresh token.
    required String refreshToken,
  }) = _AuthTokens;
}
