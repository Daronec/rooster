import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_model.dart';
import 'package:rooster/features/profile/presentation/screens/profile/profile_wm.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/desktop/profile_screen_desktop.dart';
import 'package:rooster/features/profile/presentation/screens/profile/widgets/mobile/profile_screen_mobile.dart';

/// Профиль и выход.
@RoutePage(name: 'ProfileRoute')
class ProfileScreen extends BaseWidget<ProfileScreenWidgetModel> {
  /// Создаёт экран.
  const ProfileScreen({super.key}) : super(profileScreenWidgetModelFactory);

  @override
  Widget buildDesktop(ProfileScreenWidgetModel wm) =>
      ProfileScreenDesktop(wm: wm);

  @override
  Widget buildMobile(ProfileScreenWidgetModel wm) =>
      ProfileScreenMobile(wm: wm);
}

/// Фабрика [ProfileScreenWidgetModel] с зависимостями из [IAppScope].
ProfileScreenWidgetModel profileScreenWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  return ProfileScreenWidgetModel(
    ProfileScreenModel(
      authGateway: scope.authGateway,
      authBackendStrategy: scope.authBackendStrategy,
      profileAvatarGateway: scope.profileAvatarGateway,
      profilePersonalDataGateway: scope.profilePersonalDataGateway,
      teamsGateway: scope.teamsGateway,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
