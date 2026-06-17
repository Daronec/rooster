import 'package:rooster/features/profile/data/hms_avatar_file_store_stub.dart'
    if (dart.library.io) 'package:rooster/features/profile/data/hms_avatar_file_store_io.dart'
    as hms_avatar_file_store_impl;

/// Сохранение файла аватарки на диск (только платформы с `dart:io`).
Future<String> saveHmsAvatarFile(String userId, List<int> bytes) =>
    hms_avatar_file_store_impl.saveHmsAvatarFile(userId, bytes);

/// Проверка существования файла по пути.
Future<bool> hmsAvatarFileExists(String path) =>
    hms_avatar_file_store_impl.hmsAvatarFileExists(path);
