import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/navigation/desktop_shell_navigation_host.dart';
import 'package:rooster/features/navigation/root_main_app_route.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_member_entity.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_model.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_screen.dart';
import 'package:rooster/features/profile/presentation/strings/profile_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// WM профиля.
class ProfileScreenWidgetModel
    extends BaseWidgetModel<ProfileScreen, ProfileScreenModel> {
  /// Создаёт WM.
  ProfileScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : bodyState = UnionStateNotifier<EmptyScreenBody>(
         EmptyScreenBody.instance,
       ),
       super(
         handledFailureLogWriter: logWriter,
       );

  /// Состояние тела экрана.
  final UnionStateNotifier<EmptyScreenBody> bodyState;

  /// Снимок пользователя для UI (обновляется из [ProfileScreenModel.authStateChanges]).
  final ValueNotifier<AppAuthUserEntity?> profileUserNotifier =
      ValueNotifier<AppAuthUserEntity?>(null);

  /// Локальный путь к аватарке.
  final ValueNotifier<String?> profileLocalAvatarPathNotifier =
      ValueNotifier<String?>(null);

  /// Профиль из облака ([ProfileScreenModel.profileNotifier]).
  ValueNotifier<ProfileEntity?> get profileNotifier => model.profileNotifier;

  /// Контроллер поля имени в диалоге редактирования (как в Appwrite Account `name`).
  late final TextEditingController profileDisplayNameEditController;

  StreamSubscription<AppAuthUserEntity?>? _authSubscription;

  /// Кнопка «Войти»: нет сессии и облачный вход доступен по стратегии.
  bool showSignInButton(AppAuthUserEntity? sessionUser) =>
      model.authBackendStrategy != AuthBackendStrategy.offlineOnly &&
      sessionUser == null;

  /// Редактирование аватара (галерея) доступно при активной облачной/HMS сессии.
  bool showAvatarEditButton(AppAuthUserEntity? sessionUser) =>
      sessionUser != null &&
      model.authBackendStrategy != AuthBackendStrategy.offlineOnly;

  /// Редактирование имени доступно после загрузки данных и при облачной стратегии.
  bool showPersonalDataEditButton(AppAuthUserEntity? sessionUser) =>
      sessionUser != null &&
      model.authBackendStrategy != AuthBackendStrategy.offlineOnly &&
      profileNotifier.value != null;

  /// Вернуть тело экрана в контент после ошибки.
  void retryScreenBody() {
    bodyState.content(EmptyScreenBody.instance);
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    profileDisplayNameEditController = TextEditingController();
    profileUserNotifier.value = model.user;
    unawaited(_syncLocalAvatarDisplay(model.user));
    model.bindPersonalDataForUser(model.user);
    unawaited(model.refreshTeams(model.user));
    _authSubscription = model.authStateChanges.listen((user) {
      profileUserNotifier.value = user;
      unawaited(_syncLocalAvatarDisplay(user));
      model.bindPersonalDataForUser(user);
      unawaited(model.refreshTeams(user));
    });
  }

  Future<void> _syncLocalAvatarDisplay(AppAuthUserEntity? user) async {
    if (user == null) {
      profileLocalAvatarPathNotifier.value = null;
      return;
    }
    profileLocalAvatarPathNotifier.value = await model
        .loadPersistedLocalAvatarPath(user.uid);
  }

  @override
  void dispose() {
    final subscription = _authSubscription;
    _authSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    profileDisplayNameEditController.dispose();
    profileLocalAvatarPathNotifier.dispose();
    profileUserNotifier.dispose();
    bodyState.dispose();
    super.dispose();
  }

  /// Выбор фото и сохранение (облако или локально в зависимости от бэкенда).
  void onEditAvatar() {
    unawaited(_pickAndSaveAvatar());
  }

  /// Редактирование отображаемого имени (облако).
  void onEditPersonalNames() {
    unawaited(_openEditPersonalNamesDialog());
  }

  Future<void> _openEditPersonalNamesDialog() async {
    final user = profileUserNotifier.value;
    final loadedNames = profileNotifier.value;
    if (user == null ||
        loadedNames == null ||
        !showPersonalDataEditButton(user)) {
      return;
    }
    profileDisplayNameEditController.text = loadedNames.firstName;
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(ProfileStrings.editPersonalNamesTitle(dialogContext)),
          content: TextField(
            controller: profileDisplayNameEditController,
            decoration: InputDecoration(
              labelText: ProfileStrings.firstNameLabel(dialogContext),
              counterText: '',
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 128,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                ProfileStrings.editPersonalNamesCancel(dialogContext),
              ),
            ),
            FilledButton(
              onPressed: () {
                unawaited(_submitPersonalNames(dialogContext, user.uid));
              },
              child: Text(ProfileStrings.editPersonalNamesSave(dialogContext)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPersonalNames(
    BuildContext dialogContext,
    String userId,
  ) async {
    final saveOkMessage = ProfileStrings.personalNamesSaved(context);
    final saveFailedMessage = ProfileStrings.personalNamesSaveFailed(context);
    try {
      await model.savePersonalData(
        userId: userId,
        firstName: profileDisplayNameEditController.text,
        lastName: '',
      );
      if (!dialogContext.mounted) {
        return;
      }
      Navigator.of(dialogContext).pop();
      model.profileNotifier.value = await model.loadPersonalData(userId);
      snackController.addSnack(
        saveOkMessage,
        messageType: SnackMessageType.success,
      );
    } on Object catch (error) {
      snackController.addSnack(
        saveFailedMessage,
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    }
  }

  Future<void> _pickAndSaveAvatar() async {
    final user = profileUserNotifier.value;
    if (user == null || !showAvatarEditButton(user)) {
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) {
      return;
    }
    try {
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        return;
      }
      await model.saveProfileAvatar(userId: user.uid, imageBytes: bytes);
      if (!context.mounted) {
        return;
      }
      profileLocalAvatarPathNotifier.value = await model
          .loadPersistedLocalAvatarPath(user.uid);
      snackController.addSnack(
        ProfileStrings.avatarUpdated(context),
        messageType: SnackMessageType.success,
      );
    } on Object catch (error) {
      if (context.mounted) {
        snackController.addSnack(
          ProfileStrings.avatarSaveFailed(context),
          messageType: SnackMessageType.error,
        );
      }
      logHandledFailureSeparateFromUserMessage(error);
    }
  }

  /// Открыть поток авторизации поверх текущего стека.
  void onOpenSignIn() {
    unawaited(context.router.root.push<void>(const AuthFlowRoute()));
  }

  /// Открыть экран настроек поверх текущего стека.
  void onOpenSettings() {
    final desktopBridge = DesktopShellNavigationHost.maybeOf(context);
    if (desktopBridge != null) {
      desktopBridge.selectTab(5);
      return;
    }
    unawaited(context.router.root.push<void>(const SettingsFlowRoute()));
  }

  /// Выход из сессии и возврат в основной UI со списком задач.
  Future<void> onSignOut() async {
    try {
      await model.signOut();
      if (!context.mounted) {
        return;
      }
      await context.router.replaceAll(rootMainAppStack(context));
    } on Object catch (e) {
      onErrorHandle(e);
    }
  }

  /// Команды Appwrite доступны в этом режиме.
  bool get showsTeamsSection => model.supportsTeams;

  /// Индикатор загрузки списка команд.
  ValueNotifier<bool> get teamsLoadingNotifier => model.teamsLoadingNotifier;

  /// Список команд.
  ValueNotifier<List<ProfileTeamCardEntity>> get teamsNotifier =>
      model.teamsNotifier;

  /// Создать команду (диалог имени).
  void onCreateTeamPressed() {
    unawaited(_openCreateTeamDialog());
  }

  /// Пригласить в команду по email (только для владельца команды).
  void onInviteToTeamPressed() {
    unawaited(_openInviteToTeamDialog());
  }

  /// Покинуть команду.
  void onLeaveTeamPressed(ProfileTeamCardEntity team) {
    unawaited(_leaveTeam(team));
  }

  /// Строка участника команды для отображения в UI.
  String teamMemberLine(ProfileTeamMemberEntity member) {
    final displayName = member.displayName.trim();
    final email = member.email.trim();
    final primary = displayName.isNotEmpty
        ? displayName
        : (email.isNotEmpty ? email : member.userId);
    final roles = member.roles.map(_localizedTeamRole).join(', ');
    final rolesSuffix = roles.isEmpty ? '' : ' ($roles)';
    final pending = member.confirm
        ? ''
        : ' — ${ProfileStrings.teamsMemberPending(context)}';
    return '$primary$rolesSuffix$pending';
  }

  String _localizedTeamRole(String role) {
    final normalizedRole = role.trim().toLowerCase();
    return switch (normalizedRole) {
      'owner' => ProfileStrings.teamsRoleOwner(context),
      'member' => ProfileStrings.teamsRoleMember(context),
      _ => role,
    };
  }

  Future<void> _openCreateTeamDialog() async {
    final user = profileUserNotifier.value;
    if (user == null || !model.supportsTeams || !context.mounted) {
      return;
    }
    final nameController = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              ProfileStrings.teamsCreateDialogTitle(dialogContext),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: ProfileStrings.teamsCreateNameLabel(dialogContext),
                counterText: '',
              ),
              maxLength: 128,
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  ProfileStrings.teamsDialogCancel(dialogContext),
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await _submitCreateTeam(
                    dialogContext,
                    user,
                    nameController.text,
                  );
                },
                child: Text(
                  ProfileStrings.teamsCreateSubmit(dialogContext),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameController.dispose();
      });
    }
  }

  Future<void> _submitCreateTeam(
    BuildContext dialogContext,
    AppAuthUserEntity user,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      snackController.addSnack(
        ProfileStrings.teamsNameRequired(context),
        messageType: SnackMessageType.error,
      );
      return;
    }
    try {
      await model.createTeam(name: trimmed, user: user);
      if (!dialogContext.mounted) {
        return;
      }
      Navigator.of(dialogContext).pop();
      snackController.addSnack(
        ProfileStrings.teamsCreateSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on AppwriteException catch (error) {
      snackController.addSnack(
        ProfileStrings.teamsOperationFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    } on Object catch (error) {
      snackController.addSnack(
        ProfileStrings.teamsOperationFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    }
  }

  Future<void> _openInviteToTeamDialog() async {
    final user = profileUserNotifier.value;
    if (user == null || !model.supportsTeams || !context.mounted) {
      return;
    }
    final ownedTeams = model.teamsNotifier.value
        .where((team) => team.currentUserIsOwner)
        .toList();
    if (ownedTeams.isEmpty) {
      return;
    }
    final emailController = TextEditingController();
    var selectedTeamId = ownedTeams.first.teamId;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  ProfileStrings.teamsInviteDialogTitle(dialogContext),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (ownedTeams.length > 1) ...<Widget>[
                        Text(
                          ProfileStrings.teamsInvitePickTeamLabel(
                            dialogContext,
                          ),
                        ),
                        const Height(AppSizes.double4),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedTeamId,
                          items: ownedTeams
                              .map(
                                (team) => DropdownMenuItem<String>(
                                  value: team.teamId,
                                  child: Text(team.teamName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedTeamId = value;
                            });
                          },
                        ),
                      ],
                      if (ownedTeams.length > 1)
                        const Height(AppSizes.double12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: ProfileStrings.teamsInviteEmailLabel(
                            dialogContext,
                          ),
                          counterText: '',
                        ),
                        maxLength: 254,
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      ProfileStrings.teamsDialogCancel(dialogContext),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await _submitInviteToTeam(
                        dialogContext,
                        user,
                        selectedTeamId,
                        emailController.text,
                      );
                    },
                    child: Text(
                      ProfileStrings.teamsInviteSubmit(dialogContext),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emailController.dispose();
      });
    }
  }

  Future<void> _submitInviteToTeam(
    BuildContext dialogContext,
    AppAuthUserEntity user,
    String teamId,
    String email,
  ) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      snackController.addSnack(
        ProfileStrings.teamsEmailRequired(context),
        messageType: SnackMessageType.error,
      );
      return;
    }
    try {
      await model.inviteToTeam(
        teamId: teamId,
        email: trimmed,
        invitationReturnUrl: model.teamInvitationReturnUrl,
        user: user,
      );
      if (!dialogContext.mounted) {
        return;
      }
      Navigator.of(dialogContext).pop();
      snackController.addSnack(
        ProfileStrings.teamsInviteSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on AppwriteException catch (error) {
      final message =
          error.code == 501 &&
              error.type == 'user_auth_method_unsupported' &&
              (error.message ?? '').contains(
                'Invites authentication is disabled for this project',
              )
          ? ProfileStrings.teamsInvitesDisabled(context)
          : ProfileStrings.teamsOperationFailed(context);
      snackController.addSnack(
        message,
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    } on Object catch (error) {
      snackController.addSnack(
        ProfileStrings.teamsOperationFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    }
  }

  Future<void> _leaveTeam(ProfileTeamCardEntity team) async {
    final user = profileUserNotifier.value;
    if (user == null || !model.supportsTeams) {
      return;
    }
    try {
      await model.leaveTeam(
        teamId: team.teamId,
        membershipId: team.currentUserMembershipId,
        user: user,
      );
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        ProfileStrings.teamsLeaveSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on AppwriteException catch (error) {
      snackController.addSnack(
        ProfileStrings.teamsOperationFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    } on Object catch (error) {
      snackController.addSnack(
        ProfileStrings.teamsOperationFailed(context),
        messageType: SnackMessageType.error,
      );
      logHandledFailureSeparateFromUserMessage(error);
    }
  }
}
