import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/desktop/auth_desktop_content.dart';

/// Экран входа (desktop).
class AuthScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const AuthScreenDesktop({required this.wm, super.key});

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AuthDesktopContent(wm: wm);
  }
}
