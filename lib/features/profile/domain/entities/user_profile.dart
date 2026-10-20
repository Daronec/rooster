import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';

/// Объединённый профиль пользователя, сочетающий auth identity и cloud profile данные.
///
/// Это единый источник правды для данных о пользователе во всём приложении.
/// Объединяет [AppAuthUserEntity] (auth identity от OAuth провайдеров)
/// с [ProfileEntity] (cloud profile данные) в едином view model.
final class UserProfile {
  /// Создаёт объединённый профиль пользователя.
  const UserProfile({
    required this.authUser,
    this.cloudProfile,
  });

  /// Auth identity (всегда присутствует при логине пользователя).
  final AppAuthUserEntity authUser;

  /// Cloud profile данные (null пока не загружены или если не доступны).
  final ProfileEntity? cloudProfile;

  /// Отображаемое имя: предпочитает cloud profile firstName,
  /// иначе fallback на auth displayName, email или uid.
  String get displayName {
    final firstName = cloudProfile?.firstName.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }
    return authUser.displayName ?? authUser.email ?? authUser.uid;
  }

  /// Полное имя: "firstName lastName" из cloud profile.
  String? get fullName {
    if (cloudProfile == null) return null;
    final parts = <String>[
      if (cloudProfile!.firstName.trim().isNotEmpty) cloudProfile!.firstName.trim(),
      if (cloudProfile!.lastName.trim().isNotEmpty) cloudProfile!.lastName.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// URL аватара: photoUrl из auth identity.
  /// Примечание: cloud avatarId требует gateway для загрузки изображения.
  String? get avatarUrl => authUser.photoUrl;

  /// Загружены ли данные cloud profile (даже если пустые).
  bool get hasCloudProfile => cloudProfile != null;

  /// Полностью ли настроен профиль (есть хотя бы имя в cloud profile).
  bool get isProfileComplete {
    if (cloudProfile == null) return false;
    return cloudProfile!.firstName.trim().isNotEmpty ||
        cloudProfile!.lastName.trim().isNotEmpty;
  }

  /// Создаёт копию с обновлёнными данными cloud profile.
  UserProfile copyWith({ProfileEntity? cloudProfile}) {
    return UserProfile(
      authUser: authUser,
      cloudProfile: cloudProfile,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          authUser.uid == other.authUser.uid &&
          cloudProfile?.userId == other.cloudProfile?.userId;

  @override
  int get hashCode => authUser.uid.hashCode;
}
