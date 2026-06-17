import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Загружает корневой `.env` из Flutter assets (см. `pubspec.yaml`).
///
/// [isOptional]: если файла нет (CI без секретов) — приложение стартует с пустыми ключами.
Future<void> loadAppDotEnv() async {
  await dotenv.load(isOptional: true);
}
