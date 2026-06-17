/// Заглушка для платформ без `dart:io` (web).
Future<String> saveHmsAvatarFile(String userId, List<int> bytes) async {
  throw UnsupportedError('hms_avatar_file_store unsupported on this platform');
}

/// Заглушка: файла нет.
Future<bool> hmsAvatarFileExists(String path) async => false;
