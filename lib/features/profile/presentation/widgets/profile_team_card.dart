import 'package:flutter/material.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Виджет карточки команды
class ProfileTeamCard extends StatelessWidget {
  ///
  const ProfileTeamCard({
    required this.widgetModel,
    required this.team,
    required this.onLeave,
    super.key,
  });

  /// Сущность команды
  final ProfileTeamCardEntity team;

  /// Коллбэк приглашения
  final VoidCallback onLeave;

  /// Widget model профиля.
  final ProfileScreenWidgetModel widgetModel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.double12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  team.teamName,
                  style: textScheme.body.t16Medium,
                ),
                InkWell(
                  onTap: widgetModel.onInviteToTeamPressed,
                  child: CircleAvatar(
                    backgroundColor: colorScheme.primaryNormal,
                    radius: AppSizes.double16,
                    child: const Center(
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
            const Height(AppSizes.double8),
            Text(
              ProfileStrings.teamsMembersLabel(context),
              style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
            ),
            const Height(AppSizes.double4),
            ...team.members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(top: AppSizes.double4),
                child: Text(
                  widgetModel.teamMemberLine(member),
                  style: textScheme.body.t14,
                ),
              ),
            ),
            const Height(AppSizes.double12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onLeave,
                child: Text(
                  ProfileStrings.teamsLeaveButton(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
