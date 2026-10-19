import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Загружает корневой `.env` из Flutter assets (см. `pubspec.yaml`).
///
/// [isOptional]: если файла нет (CI без секретов) — приложение стартует с пустыми ключами.
Future<void> loadAppDotEnv() async {
  await dotenv.load(isOptional: true);
}

/// Конфигурация из `.env` для OAuth-провайдеров.
abstract final class AppDotenv {
  static String get vkIdClientId =>
      dotenv.get('VK_ID_CLIENT_ID', fallback: '');

  static String get yandexIdClientId =>
      dotenv.get('YANDEX_ID_CLIENT_ID', fallback: '');
}
