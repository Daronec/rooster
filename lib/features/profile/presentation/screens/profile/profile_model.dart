import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';

/// Модель профиля.
final class ProfileScreenModel extends ElementaryModel {
  /// Создаёт модель.
  ProfileScreenModel({
    required IAuthGateway authGateway,
    required AuthBackendStrategy authBackendStrategy,
    required IProfileAvatarGateway profileAvatarGateway,
    required IProfilePersonalDataGateway profilePersonalDataGateway,
    required ITeamsGateway teamsGateway,
  }) : _authGateway = authGateway,
       _authBackendStrategy = authBackendStrategy,
       _profileAvatarGateway = profileAvatarGateway,
       _profilePersonalDataGateway = profilePersonalDataGateway,
       _teamsGateway = teamsGateway;

  final IAuthGateway _authGateway;
  final AuthBackendStrategy _authBackendStrategy;
  final IProfileAvatarGateway _profileAvatarGateway;
  final IProfilePersonalDataGateway _profilePersonalDataGateway;
  final ITeamsGateway _teamsGateway;

  StreamSubscription<ProfileEntity>? _personalNamesSubscription;

  /// Профиль из облака; `null` — загрузка или нет пользователя.
  final ValueNotifier<ProfileEntity?> profileNotifier =
      ValueNotifier<ProfileEntity?>(null);

  /// Загрузка списка команд (Appwrite).
  final ValueNotifier<bool> teamsLoadingNotifier = ValueNotifier<bool>(false);

  /// Команды текущего пользователя.
  final ValueNotifier<List<ProfileTeamCardEntity>> teamsNotifier =
      ValueNotifier<List<ProfileTeamCardEntity>>(<ProfileTeamCardEntity>[]);

  /// Стратегия облака (в режиме только офлайн вход с профиля не предлагается).
  AuthBackendStrategy get authBackendStrategy => _authBackendStrategy;

  /// Доступны команды Appwrite.
  bool get supportsTeams =>
      _authBackendStrategy == AuthBackendStrategy.appwrite;

  /// URL для письма приглашения в команду (как в OAuth Appwrite).
  String get teamInvitationReturnUrl =>
      _teamsGateway.teamInvitationReturnUrl;

  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges =>
      _authGateway.authStateChanges;

  /// Текущий пользователь.
  AppAuthUserEntity? get user => _authGateway.currentUser;

  /// Локальный путь к аватарке (HMS).
  Future<String?> loadPersistedLocalAvatarPath(String userId) =>
      _profileAvatarGateway.getPersistedLocalAvatarPath(userId);

  /// Сохранить аватар из байтов изображения.
  Future<void> saveProfileAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) => _profileAvatarGateway.saveAvatar(
    userId: userId,
    imageBytes: imageBytes,
  );

  /// Привязать [profileNotifier] к пользователю (облачный stream или офлайн).
  void bindPersonalDataForUser(AppAuthUserEntity? user) {
    unawaited(_personalNamesSubscription?.cancel());
    _personalNamesSubscription = null;
    profileNotifier.value = null;
    if (user == null) {
      return;
    }
    if (_authBackendStrategy == AuthBackendStrategy.offlineOnly) {
      profileNotifier.value = ProfileEntity(userId: user.uid);
      return;
    }
    _personalNamesSubscription = _profilePersonalDataGateway
        .watchPersonalData(user.uid)
        .listen(
          (entity) {
            profileNotifier.value = entity;
          },
          onError: (Object error, StackTrace stackTrace) {
            handleError(error, stackTrace: stackTrace);
          },
        );
  }

  /// Перезагрузить профиль (после сохранения на HMS).
  Future<ProfileEntity> loadPersonalData(String userId) =>
      _profilePersonalDataGateway.loadPersonalData(userId);

  /// Сохранить имя и фамилию в облаке.
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName,
  }) => _profilePersonalDataGateway.savePersonalData(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
  );

  /// Выход.
  Future<void> signOut() => _authGateway.signOut();

  /// Обновить список команд; при офлайне или без пользователя — пустой список.
  Future<void> refreshTeams(AppAuthUserEntity? user) async {
    if (!supportsTeams || user == null) {
      teamsNotifier.value = <ProfileTeamCardEntity>[];
      teamsLoadingNotifier.value = false;
      return;
    }
    teamsLoadingNotifier.value = true;
    try {
      teamsNotifier.value =
          await _teamsGateway.loadTeamsWithMembers(user.uid);
    } on Object catch (error, stackTrace) {
      teamsNotifier.value = <ProfileTeamCardEntity>[];
      handleError(error, stackTrace: stackTrace);
    } finally {
      teamsLoadingNotifier.value = false;
    }
  }

  /// Создать команду и обновить список.
  Future<void> createTeam({
    required String name,
    required AppAuthUserEntity user,
  }) async {
    await _teamsGateway.createTeam(name: name, currentUserId: user.uid);
    await refreshTeams(user);
  }

  /// Пригласить участника по email.
  Future<void> inviteToTeam({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
    required AppAuthUserEntity user,
  }) async {
    await _teamsGateway.inviteByEmail(
      teamId: teamId,
      email: email,
      invitationReturnUrl: invitationReturnUrl,
    );
    await refreshTeams(user);
  }

  /// Покинуть команду.
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
    required AppAuthUserEntity user,
  }) async {
    await _teamsGateway.leaveTeam(
      teamId: teamId,
      membershipId: membershipId,
    );
    await refreshTeams(user);
  }

  @override
  void dispose() {
    unawaited(_personalNamesSubscription?.cancel());
    _personalNamesSubscription = null;
    teamsLoadingNotifier.dispose();
    teamsNotifier.dispose();
    profileNotifier.dispose();
    super.dispose();
  }
}
