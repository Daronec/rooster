import 'dart:io';

import 'package:flutter/widgets.dart';

/// Реализация для платформ с `dart:io` (см. [profileLocalAvatarImage]).
Widget? profileLocalAvatarImage({
  required String? localFilePath,
  required double size,
}) {
  if (localFilePath == null || localFilePath.isEmpty) {
    return null;
  }
  return Image.file(
    File(localFilePath),
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
  );
}
