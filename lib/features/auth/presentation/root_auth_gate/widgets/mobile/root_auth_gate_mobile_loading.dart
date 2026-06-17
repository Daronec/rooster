import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/strings/root_auth_gate_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Загрузка корневого шлюза (mobile).
class RootAuthGateMobileLoading extends StatelessWidget {
  /// Создаёт виджет.
  const RootAuthGateMobileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return Scaffold(
      backgroundColor: colorScheme.gray100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: colorScheme.primaryNormal,
                  strokeWidth: 3,
                ),
              ),
              const Height(AppSizes.double16),
              Text(
                RootAuthGateStrings.loadingBody(context),
                textAlign: TextAlign.center,
                style: textScheme.body.t16Medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
