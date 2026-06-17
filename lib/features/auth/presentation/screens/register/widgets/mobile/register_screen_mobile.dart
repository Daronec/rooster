import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_wm.dart';
import 'package:rooster/features/auth/presentation/screens/register/widgets/mobile/register_mobile_content.dart';

/// Экран регистрации (mobile).
class RegisterScreenMobile extends StatelessWidget {
  /// Создаёт оболочку.
  const RegisterScreenMobile({required this.wm, super.key});

  /// Widget model.
  final RegisterScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return RegisterMobileContent(wm: wm);
  }
}
