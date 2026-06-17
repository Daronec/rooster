import 'package:flutter/material.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';

/// Цвета снэка по типу сообщения (единая точка вместо повторяющихся `switch` в UI).
extension SnackMessageTypeSnackStyle on SnackMessageType {
  /// Фон плашки снэка.
  Color snackBackgroundColor(
    AppColorScheme scheme, {
    required bool isDesktopLayout,
  }) {
    return switch (this) {
      SnackMessageType.error => scheme.red,
      SnackMessageType.warning => scheme.red,
      SnackMessageType.success => isDesktopLayout ? scheme.gray : scheme.green,
    };
  }

  /// Цвет текста на плашке снэка.
  Color snackForegroundColor(AppColorScheme scheme) {
    return switch (this) {
      SnackMessageType.error || SnackMessageType.warning => scheme.white,
      SnackMessageType.success => scheme.black,
    };
  }
}
