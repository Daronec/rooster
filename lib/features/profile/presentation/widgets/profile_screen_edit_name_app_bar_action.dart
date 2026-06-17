import 'package:flutter/material.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';

/// Кнопка «Редактировать имя» в [AppBar] (видна при облачной сессии и загруженном профиле).
class ProfileScreenEditNameAppBarAction extends StatelessWidget {
  /// Создаёт виджет.
  const ProfileScreenEditNameAppBarAction({required this.wm, super.key});

  /// Widget model экрана профиля.
  final ProfileScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppAuthUserEntity?>(
      valueListenable: wm.profileUserNotifier,
      builder: (context, sessionUser, _) {
        return ValueListenableBuilder<ProfileEntity?>(
          valueListenable: wm.profileNotifier,
          builder: (context, cloudProfile, _) {
            if (sessionUser == null || cloudProfile == null) {
              return const SizedBox.shrink();
            }
            if (!wm.showPersonalDataEditButton(sessionUser)) {
              return const SizedBox.shrink();
            }
            final tooltip = ProfileStrings.editPersonalNamesButton(context);
            return IconButton(
              tooltip: tooltip,
              onPressed: wm.onEditPersonalNames,
              icon: const Icon(Icons.edit_outlined),
            );
          },
        );
      },
    );
  }
}
