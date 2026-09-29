import 'package:flutter/material.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_member_entity.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Callback для форматирования строки участника.
typedef MemberLineFormatter = String Function(ProfileTeamMemberEntity);

/// Карточка команды.
class ProfileTeamCard extends StatelessWidget {
  /// Создаёт карточку команды.
  const ProfileTeamCard({
    required this.team,
    required this.onInvitePressed,
    required this.onLeavePressed,
    required this.memberLineFormatter,
    super.key,
  });

  /// Карточка команды.
  final ProfileTeamCardEntity team;

  /// Callback для приглашения в команду.
  final VoidCallback onInvitePressed;

  /// Callback для выхода из команды.
  final VoidCallback onLeavePressed;

  /// Форматирование строки участника.
  final MemberLineFormatter memberLineFormatter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.double12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.double16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    team.teamName,
                    style: const TextStyle(
                      fontSize: AppSizes.double16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (team.currentUserIsOwner) ...<Widget>[
                  Icon(
                    Icons.verified_user,
                    size: AppSizes.double18,
                    color: colorScheme.primaryNormal,
                  ),
                  const Width(AppSizes.double8),
                ],
                if (team.currentUserIsOwner)
                  IconButton(
                    icon: const Icon(Icons.email_outlined, size: AppSizes.double18),
                    onPressed: onInvitePressed,
                    tooltip: ProfileStrings.teamsInviteDialogTitle(context),
                  ),
                if (!team.currentUserIsOwner)
                  IconButton(
                    icon: const Icon(Icons.exit_to_app, size: AppSizes.double18),
                    onPressed: onLeavePressed,
                    tooltip: ProfileStrings.teamsLeaveButton(context),
                  ),
              ],
            ),
            const Height(AppSizes.double8),
            Text(
              ProfileStrings.teamsMembersLabel(context),
              style: const TextStyle(
                fontSize: AppSizes.double12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Height(AppSizes.double4),
            ...team.members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.double4),
                child: Text(
                  memberLineFormatter(member),
                  style: const TextStyle(fontSize: AppSizes.double14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Расширение для Width.
class Width extends StatelessWidget {
  /// Создаёт горизонтальный отступ.
  const Width(this.width, {super.key});

  /// Ширина отступа.
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
