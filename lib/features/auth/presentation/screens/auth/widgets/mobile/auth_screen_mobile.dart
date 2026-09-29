import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart';

/// Экран входа (mobile).
class AuthScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const AuthScreenMobile({required this.wm, super.key});

  /// Widget model экрана авторизации.
  final AuthScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AuthMobileContent(wm: wm);
  }
}
