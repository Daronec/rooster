import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/widgets/task_attachment_preview_stub.dart'
    if (dart.library.io)
      'package:rooster/features/tasks/presentation/widgets/task_attachment_preview_io.dart'
    as preview_impl;

/// Миниатюра локального изображения задачи (на мобильных — [Image.file], на вебе — иконка).
Widget taskAttachmentPreview(String? path, {double size = 96}) {
  return preview_impl.taskAttachmentPreview(path, size: size);
}
