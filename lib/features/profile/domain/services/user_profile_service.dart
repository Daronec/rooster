import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/entities/user_profile.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';
import 'package:union_state/union_state.dart';

/// Сервис, предоставляющий объединённый stream-based view данных профиля пользователя.
///
/// Слушает изменения auth gateway и, когда пользователь авторизован,
/// подписывается на поток cloud profile данных. Объединяет оба источника
/// в единый `Stream<UserProfile>` с состояниями loading/content/error.
///
/// Использование: `context.read<IAppScope>().userProfileService.userProfileStream`
final class UserProfileService extends ElementaryModel {
  /// Создаёт сервис.
  UserProfileService({
    required IAuthGateway authGateway,
    required IProfilePersonalDataGateway profilePersonalDataGateway,
  })  : _authGateway = authGateway,
        _profilePersonalDataGateway = profilePersonalDataGateway;

  final IAuthGateway _authGateway;
  final IProfilePersonalDataGateway _profilePersonalDataGateway;

  /// Текущий auth user (для синхронного доступа).
  AppAuthUserEntity? get currentAuthUser => _authGateway.currentUser;

  /// Текущий объединённый UserProfile (null если пользователь не вошёл).
  UserProfile? get currentProfile => _currentProfile;
  UserProfile? _currentProfile;

  /// Поток состояний объединённого профиля пользователя.
  ///
  /// Эмитирует:
  /// - `UnionStateLoading<UserProfile>` при загрузке profile данных
  /// - `UnionStateContent<UserProfile>` когда данные доступны
  /// - `UnionStateFailure<UserProfile>` при ошибках
  late final Stream<UnionState<UserProfile>> userProfileStream;

  @override
  void init() {
    super.init();
    userProfileStream = _buildUserProfileStream();
  }

  Stream<UnionState<UserProfile>> _buildUserProfileStream() {
    return _authGateway.authStateChanges
        .asyncMap<UserProfile>((authUser) async {
      if (authUser == null) {
        return UserProfile(
          authUser: const AppAuthUserEntity(uid: '', isAnonymous: false),
        );
      }

      // Пытаемся загрузить profile данные
      ProfileEntity? profile;
      try {
        // Используем first из watch stream для начальной загрузки
        profile = await _profilePersonalDataGateway
            .watchPersonalData(authUser.uid)
            .first;
      } on UnimplementedError {
        // Noop gateway — профиль недоступен
        profile = null;
      } on StateError {
        // Stream завершился без эмиссии (Noop или пустой)
        profile = null;
      } catch (_) {
        // Любая другая ошибка — profile остаётся null
        profile = null;
      }

      return UserProfile(
        authUser: authUser,
        cloudProfile: profile,
      );
    }).map<UnionState<UserProfile>>((profile) {
      if (profile.authUser.uid.isEmpty) {
        // Пользователь вышел
        return UnionStateContent<UserProfile>(profile);
      }
      // Профиль загружен (даже если cloudProfile == null)
      return UnionStateContent<UserProfile>(profile);
    }).startWith(const UnionStateLoading<UserProfile>());
  }

  /// Загрузить profile данные для конкретного пользователя (разово, например после ручного обновления).
  Future<UserProfile> loadUserProfile(String userId) async {
    final authUser = _authGateway.currentUser;
    if (authUser == null || authUser.uid != userId) {
      throw StateError(
          'User mismatch: expected $userId, got ${authUser?.uid}');
    }

    final profile = await _profilePersonalDataGateway.loadPersonalData(userId);
    final updated = UserProfile(
      authUser: authUser,
      cloudProfile: profile,
    );
    _currentProfile = updated;
    return updated;
  }

  /// Сохранить личные данные и обновить локальный кэш профиля.
  Future<void> savePersonalData({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    await _profilePersonalDataGateway.savePersonalData(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
    );
    // Watch stream должен автоматически эмитировать обновлённый профиль.
    // Если watch недоступен (Noop), перезагружаем вручную.
    try {
      final profile = await _profilePersonalDataGateway.loadPersonalData(userId);
      if (_currentProfile?.authUser.uid == userId) {
        _currentProfile = _currentProfile!.copyWith(cloudProfile: profile);
      }
    } on UnimplementedError {
      // Noop gateway — нечего перезагружать
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
