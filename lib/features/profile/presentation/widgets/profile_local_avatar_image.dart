import 'package:flutter/widgets.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_local_avatar_image_stub.dart'
    if (dart.library.io) 'package:rooster/features/profile/presentation/widgets/profile_local_avatar_image_io.dart'
    as profile_local_avatar_image_impl;

/// Виджет локального файла аватарки или `null`, если путь пустой / платформа без `dart:io`.
Widget? profileLocalAvatarImage({
  required String? localFilePath,
  required double size,
}) => profile_local_avatar_image_impl.profileLocalAvatarImage(
  localFilePath: localFilePath,
  size: size,
);
