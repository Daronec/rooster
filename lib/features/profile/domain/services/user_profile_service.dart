import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/entities/user_profile.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';
import 'package:union_state/union_state.dart';

/// Интерфейс для сервиса профиля пользователя.
///
/// Позволяет использовать composition-based fakes в тестах
/// (UserProfileService — final class).
abstract interface class IUserProfileService {
  /// Текущий объединённый UserProfile (null если пользователь не вошёл).
  UserProfile? get currentProfile;

  /// Текущий auth user (для синхронного доступа).
  AppAuthUserEntity? get currentAuthUser;

  /// Запустить слушание изменений auth и загрузить профиль.
  void init();

  /// Остановить слушание и освободить ресурсы.
  void dispose();
}

/// Сервис, предоставляющий value-listenable view данных профиля пользователя.
///
/// Слушает изменения auth gateway и, когда пользователь авторизован,
/// подписывается на поток cloud profile данных. Объединяет оба источника
/// в единый `ValueNotifier<UnionState<UserProfile>>` с состояниями loading/content/error.
///
/// Использование: `context.read<IAppScope>().userProfileService.userProfileState`
final class UserProfileService implements IUserProfileService {
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

  /// Состояние объединённого профиля пользователя.
  ///
  /// Эмитирует:
  /// - `UnionStateLoading<UserProfile>` при загрузке profile данных
  /// - `UnionStateContent<UserProfile>` когда данные доступны
  /// - `UnionStateFailure<UserProfile>` при ошибках
  final ValueNotifier<UnionState<UserProfile>> userProfileState =
      ValueNotifier<UnionState<UserProfile>>(
        const UnionStateLoading<UserProfile>(),
      );

  StreamSubscription<AppAuthUserEntity?>? _authSubscription;

  /// Запустить слушание изменений auth и загрузить профиль.
  void init() {
    _authSubscription = _authGateway.authStateChanges.listen(_onAuthStateChanged);
    // Начальная загрузка
    unawaited(_onAuthStateChanged(_authGateway.currentUser));
  }

  /// Обработка изменения состояния авторизации.
  Future<void> _onAuthStateChanged(AppAuthUserEntity? authUser) async {
    if (authUser == null) {
      userProfileState.value = UnionStateContent<UserProfile>(
        UserProfile(
          authUser: const AppAuthUserEntity(uid: '', isAnonymous: false),
        ),
      );
      return;
    }

    userProfileState.value = const UnionStateLoading<UserProfile>();

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

    final userProfile = UserProfile(
      authUser: authUser,
      cloudProfile: profile,
    );
    _currentProfile = userProfile;
    userProfileState.value = UnionStateContent<UserProfile>(userProfile);
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
    userProfileState.value = UnionStateContent<UserProfile>(updated);
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
        userProfileState.value = UnionStateContent<UserProfile>(_currentProfile!);
      }
    } on UnimplementedError {
      // Noop gateway — нечего перезагружать
    }
  }

  /// Остановить слушание и освободить ресурсы.
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    userProfileState.dispose();
  }
}
