import 'package:flutter/material.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_team_card.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Секция команд на экране профиля.
class ProfileTeamsSection extends StatelessWidget {
  /// Создаёт секцию команд.
  const ProfileTeamsSection({required this.widgetModel, super.key});

  /// Widget model профиля.
  final ProfileScreenWidgetModel widgetModel;

  @override
  Widget build(BuildContext context) {
    if (!widgetModel.showsTeamsSection) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Height(AppSizes.double16),
        Row(
          children: <Widget>[
            Text(
              ProfileStrings.teamsSectionTitle(context),
              style: const TextStyle(
                fontSize: AppSizes.double18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: widgetModel.teamsLoadingNotifier,
              builder: (context, loading, _) {
                if (loading) {
                  return const SizedBox(
                    width: AppSizes.double20,
                    height: AppSizes.double20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.add, size: AppSizes.double20),
                  onPressed: widgetModel.onCreateTeamPressed,
                  tooltip: ProfileStrings.teamsCreateDialogTitle(context),
                );
              },
            ),
          ],
        ),
        const Height(AppSizes.double8),
        ValueListenableBuilder<List<ProfileTeamCardEntity>>(
          valueListenable: widgetModel.teamsNotifier,
          builder: (context, teams, _) {
            if (teams.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.double16),
                child: Center(
                  child: Text(
                    ProfileStrings.teamsEmpty(context),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teams.length,
              separatorBuilder: (_, __) => const Height(AppSizes.double8),
              itemBuilder: (context, index) {
                final team = teams[index];
                return ProfileTeamCard(
                  team: team,
                  onInvitePressed: widgetModel.onInviteToTeamPressed,
                  onLeavePressed: () => widgetModel.onLeaveTeamPressed(team),
                  memberLineFormatter: widgetModel.teamMemberLine,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
