// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана профиля (`profile.*`).
final class ProfileStrings {
  ProfileStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.screenTitle');

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.retryBody');

  static String avatarSemanticsLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.avatarSemanticsLabel');

  static String avatarUpdated(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.avatarUpdated');

  static String avatarSaveFailed(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.avatarSaveFailed');

  static String firstNameLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.firstNameLabel');

  static String lastNameLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.lastNameLabel');

  static String nameNotSetPlaceholder(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.nameNotSetPlaceholder');

  static String editPersonalNamesTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.editPersonalNamesTitle');

  static String editPersonalNamesSave(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.editPersonalNamesSave');

  static String editPersonalNamesCancel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.editPersonalNamesCancel');

  static String editPersonalNamesButton(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.editPersonalNamesButton');

  static String personalNamesSaved(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.personalNamesSaved');

  static String personalNamesSaveFailed(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.personalNamesSaveFailed');

  static String avatarIdLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.avatarIdLabel');

  static String notSignedIn(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.notSignedIn');

  static String signInButton(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.signInButton');

  static String signOutButton(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.signOutButton');

  static String teamsSectionTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsSectionTitle');

  static String teamsEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsEmpty');

  static String teamsMembersLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsMembersLabel');

  static String teamsMemberPending(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsMemberPending');

  static String teamsRoleOwner(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsRoleOwner');

  static String teamsRoleMember(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsRoleMember');

  static String teamsLeaveButton(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsLeaveButton');

  static String teamsCreateDialogTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsCreateDialogTitle');

  static String teamsCreateNameLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsCreateNameLabel');

  static String teamsCreateSubmit(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsCreateSubmit');

  static String teamsDialogCancel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsDialogCancel');

  static String teamsInviteDialogTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsInviteDialogTitle');

  static String teamsInvitePickTeamLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsInvitePickTeamLabel');

  static String teamsInviteEmailLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsInviteEmailLabel');

  static String teamsInviteSubmit(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsInviteSubmit');

  static String teamsNameRequired(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsNameRequired');

  static String teamsEmailRequired(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsEmailRequired');

  static String teamsCreateSuccess(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsCreateSuccess');

  static String teamsInviteSuccess(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsInviteSuccess');

  static String teamsLeaveSuccess(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsLeaveSuccess');

  static String teamsInvitesDisabled(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsInvitesDisabled');

  static String teamsOperationFailed(BuildContext context) =>
      FlutterI18n.translate(context, 'profile.teamsOperationFailed');
}
