import 'package:flutter/material.dart';

/// Превью вложения без `dart:io` (веб).
Widget taskAttachmentPreview(String? path, {double size = 96}) {
  if (path == null || path.isEmpty) {
    return const SizedBox.shrink();
  }
  return Icon(Icons.image_outlined, size: size);
}
