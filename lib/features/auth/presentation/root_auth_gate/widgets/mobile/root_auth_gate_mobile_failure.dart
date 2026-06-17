import 'package:flutter/material.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_wm.dart';
import 'package:rooster/features/auth/presentation/strings/root_auth_gate_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Ошибка корневого шлюза (mobile).
class RootAuthGateMobileFailure extends StatelessWidget {
  /// Создаёт виджет.
  const RootAuthGateMobileFailure({
    required this.wm,
    required this.error,
    super.key,
  });

  /// Widget model шлюза.
  final RootAuthGateWidgetModel wm;

  /// Ошибка.
  final Object error;

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
              Text(
                RootAuthGateStrings.loadError(context),
                textAlign: TextAlign.center,
                style: textScheme.body.t16Bold,
              ),
              const Height(AppSizes.double8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
              ),
              const Height(AppSizes.double16),
              FilledButton.tonal(
                onPressed: wm.retryRootFlow,
                child: Text(RootAuthGateStrings.retryBody(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
