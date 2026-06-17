import 'package:flutter/material.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_local_avatar_image.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_teams_section.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Тело экрана профиля: аватар, идентификатор, вход / выход.
class ProfileScreenBody extends StatelessWidget {
  /// Создаёт виджет.
  const ProfileScreenBody({required this.wm, super.key});

  /// Widget model профиля.
  final ProfileScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return ValueListenableBuilder<AppAuthUserEntity?>(
      valueListenable: wm.profileUserNotifier,
      builder: (context, sessionUser, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: wm.profileLocalAvatarPathNotifier,
          builder: (context, localAvatarPath, _) {
            return ValueListenableBuilder<ProfileEntity?>(
              valueListenable: wm.profileNotifier,
              builder: (context, cloudProfile, _) {
                final showEditAvatar = wm.showAvatarEditButton(sessionUser);
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Semantics(
                          label: ProfileStrings.avatarSemanticsLabel(
                            context,
                          ),
                          button: showEditAvatar,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              GestureDetector(
                                onTap: showEditAvatar
                                    ? wm.onEditAvatar
                                    : null,
                                child: _AvatarCircle(
                                  sessionUser: sessionUser,
                                  localAvatarPath: localAvatarPath,
                                  colorScheme: colorScheme,
                                  size: _kProfileAvatarDiameter,
                                ),
                              ),
                              if (showEditAvatar)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Material(
                                      color: colorScheme.primaryNormal,
                                      shape: const CircleBorder(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          AppSizes.double8,
                                        ),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: AppSizes.double20,
                                          color: colorScheme.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Height(AppSizes.double16),
                      if (sessionUser == null) ...<Widget>[
                        Text(
                          ProfileStrings.notSignedIn(context),
                          style: textScheme.body.t16Medium,
                          textAlign: TextAlign.center,
                        ),
                        const Height(AppSizes.double16),
                      ] else ...<Widget>[
                        if (cloudProfile == null)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSizes.double16,
                              ),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else ...<Widget>[
                          _ProfileFieldsSection(
                            profile: cloudProfile,
                            textScheme: textScheme,
                          ),
                          const Height(AppSizes.double12),
                        ],
                        Text(
                          sessionUser.email ??
                              sessionUser.displayName ??
                              sessionUser.uid,
                          style: textScheme.body.t12.copyWith(
                            color: colorScheme.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Height(AppSizes.double16),
                        ProfileTeamsSection(widgetModel: wm),
                      ],
                      if (wm.showSignInButton(sessionUser))
                        AppPrimaryButton(
                          onPressed: wm.onOpenSignIn,
                          child: Text(
                            ProfileStrings.signInButton(context),
                          ),
                        ),
                      if (sessionUser != null)
                        AppPrimaryButton(
                          onPressed: wm.onSignOut,
                          child: Text(
                            ProfileStrings.signOutButton(context),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static const double _kProfileAvatarDiameter = 96;
}

/// Блок полей профиля (имя, id аватара).
class _ProfileFieldsSection extends StatelessWidget {
  /// Создаёт блок.
  const _ProfileFieldsSection({
    required this.profile,
    required this.textScheme,
  });

  final ProfileEntity profile;
  final AppTextScheme textScheme;

  @override
  Widget build(BuildContext context) {
    final placeholder = ProfileStrings.nameNotSetPlaceholder(context);
    final displayNameLine = profile.firstName.trim().isEmpty
        ? placeholder
        : profile.firstName.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          ProfileStrings.firstNameLabel(context),
          style: textScheme.body.t12,
        ),
        Text(
          displayNameLine,
          style: textScheme.body.t16Medium,
        ),
        if (profile.avatarId case final String avatarStorageId
            when avatarStorageId.isNotEmpty) ...<Widget>[
          const Height(AppSizes.double8),
          Text(
            ProfileStrings.avatarIdLabel(context),
            style: textScheme.body.t12,
          ),
          SelectableText(
            avatarStorageId,
            style: textScheme.t14,
          ),
        ],
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.sessionUser,
    required this.localAvatarPath,
    required this.colorScheme,
    required this.size,
  });

  final AppAuthUserEntity? sessionUser;
  final String? localAvatarPath;
  final AppColorScheme colorScheme;
  final double size;

  @override
  Widget build(BuildContext context) {
    final localWidget = profileLocalAvatarImage(
      localFilePath: localAvatarPath,
      size: size,
    );
    final photoUrl = sessionUser?.photoUrl;
    Widget child;
    if (localWidget != null) {
      child = localWidget;
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      child = Image.network(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderIcon(colorScheme),
      );
    } else {
      child = _placeholderIcon(colorScheme);
    }
    return ClipOval(
      child: ColoredBox(
        color: colorScheme.gray200,
        child: SizedBox(
          width: size,
          height: size,
          child: child,
        ),
      ),
    );
  }

  static Widget _placeholderIcon(AppColorScheme colorScheme) {
    return Icon(
      Icons.person_outline,
      size: AppSizes.double48,
      color: colorScheme.gray600,
    );
  }
}
