import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_wm.dart';
import 'package:rooster/features/auth/presentation/screens/register/widgets/desktop/register_desktop_content.dart';

/// Экран регистрации (desktop).
class RegisterScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку.
  const RegisterScreenDesktop({required this.wm, super.key});

  /// Widget model.
  final RegisterScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return RegisterDesktopContent(wm: wm);
  }
}
