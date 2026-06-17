import 'package:flutter/material.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_wm.dart';
import 'package:rooster/features/settings/presentation/strings/settings_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Состояние загрузки экрана настроек (desktop).
class SettingsDesktopLoading extends StatelessWidget {
  /// Создаёт виджет.
  const SettingsDesktopLoading({required this.wm, super.key});

  /// Widget model экрана настроек.
  final SettingsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(SettingsStrings.screenTitle(context)),
        withBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const Height(AppSizes.double16),
              Text(SettingsStrings.loadingBody(context)),
            ],
          ),
        ),
      ),
    );
  }
}
