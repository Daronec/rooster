import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:rooster/features/locale_mode/presentation/locale_provider.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_wm.dart';
import 'package:rooster/features/settings/presentation/strings/settings_strings.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Контент экрана настроек (desktop).
class SettingsDesktopContent extends StatelessWidget {
  /// Создаёт контент.
  const SettingsDesktopContent({required this.wm, super.key});

  /// Widget model экрана настроек.
  final SettingsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: DefaultAppBar(
        title: Text(
          SettingsStrings.screenTitle(context),
        ),
        onBackButtonTap: wm.onBackPressed,
      ),
      body: ListView(
        padding: AppSizes.edgeInsetsAll16,
        children: <Widget>[
          ListTile(
            title: Text(
              SettingsStrings.toggleThemeTitle(context),
            ),
            subtitle: Text(
              SettingsStrings.toggleThemeSubtitle(context),
            ),
            onTap: wm.onToggleTheme,
          ),
          ValueListenableBuilder<Locale>(
            valueListenable: LocaleProvider.of(context).locale,
            builder: (builderContext, locale, _) {
              final languageLabel = switch (locale.languageCode) {
                'en' => SettingsStrings.languageEn(builderContext),
                _ => SettingsStrings.languageRu(builderContext),
              };
              return ListTile(
                title: Text(SettingsStrings.languageTitle(builderContext)),
                subtitle: Text(SettingsStrings.languageSubtitle(builderContext)),
                trailing: Text(languageLabel),
                onTap: () async {
                  final selected = await showDialog<String>(
                    context: builderContext,
                    builder: (dialogContext) => SimpleDialog(
                      title: Text(SettingsStrings.languageTitle(dialogContext)),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => dialogContext.router.pop('ru'),
                          child: Text(SettingsStrings.languageRu(dialogContext)),
                        ),
                        SimpleDialogOption(
                          onPressed: () => dialogContext.router.pop('en'),
                          child: Text(SettingsStrings.languageEn(dialogContext)),
                        ),
                      ],
                    ),
                  );
                  if (selected == null) return;
                  await wm.onSelectLanguage(selected);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
