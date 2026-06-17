/// Результат запроса SMS-кода для входа по телефону (например Appwrite).
final class AppPhoneOtpChallengeEntity {
  /// Создаёт значение.
  const AppPhoneOtpChallengeEntity({required this.userId});

  /// Идентификатор пользователя/потока для [completePhoneSignIn].
  final String userId;
}
