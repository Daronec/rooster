import 'package:flutter/material.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/features/profile/presentation/widgets/profile_team_card.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Блок команд Appwrite на экране профиля.
class ProfileTeamsSection extends StatelessWidget {
  /// Создаёт виджет.
  const ProfileTeamsSection({required this.widgetModel, super.key});

  /// Widget model профиля.
  final ProfileScreenWidgetModel widgetModel;

  @override
  Widget build(BuildContext context) {
    if (!widgetModel.showsTeamsSection) {
      return const SizedBox.shrink();
    }
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Height(AppSizes.double24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ProfileStrings.teamsSectionTitle(context),
              style: textScheme.body.t20Bold,
            ),
            InkWell(
              onTap: widgetModel.onCreateTeamPressed,
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
        const Height(AppSizes.double12),
        ValueListenableBuilder<bool>(
          valueListenable: widgetModel.teamsLoadingNotifier,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<List<ProfileTeamCardEntity>>(
              valueListenable: widgetModel.teamsNotifier,
              builder: (context, teams, _) {
                if (isLoading && teams.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizes.double16,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (teams.isEmpty) {
                  return Text(
                    ProfileStrings.teamsEmpty(context),
                    style: textScheme.body.t14.copyWith(
                      color: colorScheme.gray600,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final ProfileTeamCardEntity team in teams)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.double12,
                        ),
                        child: ProfileTeamCard(
                          team: team,
                          onLeave: () => widgetModel.onLeaveTeamPressed(team),
                          widgetModel: widgetModel,
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
