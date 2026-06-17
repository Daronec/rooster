import 'dart:io' show File;

import 'package:flutter/material.dart';

/// Превью локального файла изображения.
Widget taskAttachmentPreview(String? path, {double size = 96}) {
  if (path == null || path.isEmpty) {
    return const SizedBox.shrink();
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.file(
      File(path),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, size: size),
    ),
  );
}
