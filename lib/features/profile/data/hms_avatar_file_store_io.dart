import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Сохраняет байты в каталог приложения, возвращает абсолютный путь.
Future<String> saveHmsAvatarFile(String userId, List<int> bytes) async {
  final root = await getApplicationDocumentsDirectory();
  final folderPath = '${root.path}/profile_avatars';
  final folder = Directory(folderPath);
  if (!folder.existsSync()) {
    await folder.create(recursive: true);
  }
  final filePath = '$folderPath/$userId.jpg';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Проверяет, что файл по [path] существует.
Future<bool> hmsAvatarFileExists(String path) async => File(path).existsSync();
