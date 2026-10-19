# Интеграция VK ID и Yandex ID

## 1. Зависимости

Добавить в `pubspec.yaml`:

```yaml
dependencies:
  vkid_flutter_sdk: ^1.0.3
  yandex_login_sdk: ^1.0.1
  flutter_dotenv: ^6.0.1
```

## 2. Конфигурационные переменные

Создать файл `.env` в корне проекта (рядом с `pubspec.yaml`):

```env
VK_ID_CLIENT_ID=54795577
VK_ID_CLIENT_SECRET=fFYxmcEkMifGyH0B0Jpf
VK_ID_REDIRECT_URI=vk54795577://vk.ru/blank.html
VK_ID_SCOPE=email phone

YANDEX_ID_CLIENT_ID=037e36490f9c4edca3e7af17f709f057
YANDEX_ID_CLIENT_SECRET=c0104c2151134b58a211bbfe457d9d0d
YANDEX_ID_REDIRECT_URI=cadencepro://auth/yandex/callback
YANDEX_ID_SCOPE=login:info login:email login:avatar
```

Добавить в `pubspec.yaml` секцию `flutter`:

```yaml
flutter:
  assets:
    - .env
```

## 3. Android конфигурация

### 3.1. `android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ru.aronets.cadencepro"
    
    defaultConfig {
        applicationId = "ru.aronets.cadencepro"
        
        manifestPlaceholders += mapOf(
            "VKIDClientID" to (findProperty("VK_ID_CLIENT_ID") as? String ?: ""),
            "VKIDClientSecret" to "",
            "VKIDRedirectHost" to "",
            "VKIDRedirectScheme" to "vkid-\${applicationId}"
        )
        
        manifestPlaceholders += mapOf(
            "YANDEX_CLIENT_ID" to (findProperty("YANDEX_ID_CLIENT_ID") as? String ?: "")
        )
    }
}
```

### 3.2. `android/app/src/main/AndroidManifest.xml`

Добавить intent-filter для обработки OAuth callback:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    
    <!-- VK ID SDK: OAuth redirect callback -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="vk54795577" android:host="authorize"/>
    </intent-filter>

    <!-- Yandex SDK: OAuth redirect callback -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="yx037e36490f9c4edca3e7af17f709f057"/>
    </intent-filter>
</activity>
```

**Важно:** `android:scheme` для VK — это `VK_ID_CLIENT_ID`. Для Yandex — это `YANDEX_ID_CLIENT_ID` с префиксом `yx`.

## 4. Структура кода

### 4.1. Общий интерфейс `SocialSignInService`

**Файл:** `lib/features/auth/data/services/social_sign_in_service.dart`

```dart
import 'package:client_velo_app/features/auth/data/services/social_auth_service.dart';

abstract class SocialSignInService {
  SocialAuthProvider get provider;
  Future<SocialAuthResult> signIn();
}
```

### 4.2. Общий результат авторизации `SocialAuthResult`

**Файл:** `lib/features/auth/data/services/social_auth_service.dart`

```dart
enum SocialAuthProvider { vk, yandex }

final class SocialAuthCanceledException implements Exception {
  const SocialAuthCanceledException();
}

final class SocialAuthResult {
  const SocialAuthResult({
    required this.provider,
    required this.subject,
    required this.email,
    required this.accessToken,
    this.refreshToken,
    this.phone,
    this.displayName,
    this.avatarUrl,
  });

  final SocialAuthProvider provider;
  final String subject;
  final String email;
  final String accessToken;
  final String? refreshToken;
  final String? phone;
  final String? displayName;
  final String? avatarUrl;

  String get providerName => provider.name;
}
```

### 4.3. Фасад `SocialAuthService`

**Файл:** `lib/features/auth/data/services/social_auth_service.dart`

```dart
final class SocialAuthService {
  SocialAuthService({
    required this.vkIdService,
    required this.yandexIdService,
  });

  final SocialSignInService vkIdService;
  final SocialSignInService yandexIdService;

  Future<SocialAuthResult> signInWithVkId() => vkIdService.signIn();
  Future<SocialAuthResult> signInWithYandexId() => yandexIdService.signIn();
}
```

### 4.4. VK ID реализация `VkIdAuthService`

**Файл:** `lib/features/auth/data/services/vk_id_auth_service.dart`

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_config/shared_config.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';

import 'social_auth_service.dart';
import 'social_sign_in_service.dart';

final class VkIdAuthService implements SocialSignInService {
  @override
  SocialAuthProvider get provider => SocialAuthProvider.vk;

  @override
  Future<SocialAuthResult> signIn() async {
    _ensureConfigured(AppDotenv.vkIdClientId.isNotEmpty, 'VK_ID_CLIENT_ID');

    final vkid = await VKID.getInstance();
    final authData = await _authorizeVk(vkid);

    try {
      final userData = await _fetchVkUser(vkid)
          .catchError((_) => authData.userData, test: (_) => true);

      return SocialAuthResult(
        provider: provider,
        subject: authData.userID.toString(),
        email: _nonEmpty(userData.email) ?? 'vk-\${authData.userID}@vk.local',
        phone: _nonEmpty(userData.phone),
        displayName: _displayName([userData.firstName, userData.lastName]),
        avatarUrl: authData.userData.avatarUrl,
        accessToken: authData.token,
        refreshToken: authData.idToken,
      );
    } on Exception catch (e) {
      debugPrint('VK ID: fetch user exception: \$e');
      rethrow;
    }
  }

  Future<AuthData> _authorizeVk(VKID vkid) {
    final completer = Completer<AuthData>();

    vkid.authorize(
      onAuth: (authData) {
        if (!completer.isCompleted) {
          completer.complete(authData);
        }
      },
      onError: (error) {
        if (completer.isCompleted) return;
        if (error is AuthCancelledError) {
          completer.completeError(const SocialAuthCanceledException());
          return;
        }
        if (error is AuthOtherError) {
          completer.completeError(StateError(error.description));
          return;
        }
        completer.completeError(StateError('VK ID authorization failed: \$error'));
      },
      params: AuthParamsBuilder().build(),
    );

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw StateError('VK ID authorization timed out'),
    );
  }

  Future<User> _fetchVkUser(VKID vkid) {
    final completer = Completer<User>();

    vkid.fetchUser(
      onSuccess: (user) {
        if (!completer.isCompleted) {
          completer.complete(user);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(StateError(_vkFetchUserErrorMessage(error)));
        }
      },
    );

    return completer.future;
  }

  void _ensureConfigured(bool isConfigured, String key) {
    if (!isConfigured) {
      throw StateError('\$key is empty. Add it to the repository root .env.');
    }
  }

  String _vkFetchUserErrorMessage(FetchUserError error) {
    return switch (error) {
      FetchUserTokenExpiredError() => 'VK ID user token expired',
      FetchUserOtherError(:final description) =>
        'VK ID user fetch failed: \$description',
    };
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _displayName(Iterable<String?> parts) {
    final value = parts
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    return value.isEmpty ? null : value;
  }
}
```

### 4.5. Yandex ID реализация `YandexIdAuthService`

**Файл:** `lib/features/auth/data/services/yandex_id_auth_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_config/shared_config.dart';
import 'package:yandex_login_sdk/yandex_login_sdk.dart';

import 'social_auth_service.dart';
import 'social_sign_in_service.dart';

final class YandexIdAuthService implements SocialSignInService {
  @override
  SocialAuthProvider get provider => SocialAuthProvider.yandex;

  @override
  Future<SocialAuthResult> signIn() async {
    _ensureConfigured(
      AppDotenv.yandexIdClientId.isNotEmpty,
      'YANDEX_ID_CLIENT_ID',
    );

    try {
      final loginResult = await YandexLoginSdk.signIn(
        clientId: AppDotenv.yandexIdClientId,
      );

      final user = await YandexLoginSdk.getUserInfo(token: loginResult.token);
      final email =
          user.defaultEmail ??
          (user.emails.isNotEmpty ? user.emails.first : null) ??
          '\${user.login.isNotEmpty ? user.login : 'yandex-\${user.id}'}@yandex.local';

      return SocialAuthResult(
        provider: provider,
        subject: user.id,
        email: email,
        phone: user.defaultPhone?.number,
        displayName:
            _nonEmpty(user.displayName ?? '') ??
            _nonEmpty(user.realName ?? '') ??
            _displayName([user.firstName, user.lastName]) ??
            _nonEmpty(user.login),
        avatarUrl: _avatarUrl(user),
        accessToken: loginResult.token,
      );
    } on YandexAuthCancelledException {
      throw const SocialAuthCanceledException();
    }
  }

  void _ensureConfigured(bool isConfigured, String key) {
    if (!isConfigured) {
      throw StateError('\$key is empty. Add it to the repository root .env.');
    }
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _displayName(Iterable<String?> parts) {
    final value = parts
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    return value.isEmpty ? null : value;
  }

  String? _avatarUrl(user) {
    final photo = user.defaultPhoto ?? user.photos?.firstOrNull;
    final trimmed = photo?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
```

## 5. Загрузка конфигурации

**Файл:** `packages/shared_config/lib/config/app_dotenv.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadAppDotEnv() async {
  await dotenv.load(fileName: '.env', isOptional: true);
}

abstract final class AppDotenv {
  static String get vkIdClientId => dotenv.get('VK_ID_CLIENT_ID', fallback: '');
  static String get yandexIdClientId =>
      dotenv.get('YANDEX_ID_CLIENT_ID', fallback: '');
}
```

## 6. DI и использование

### 6.1. Создание сервисов

**Файл:** `lib/features/auth/presentation/screens/auth/auth_wm.dart`

```dart
AuthWM defaultAuthWMFactory(BuildContext context) {
  final scope = context.read<IAuthScope>();
  final snackController = SnackQueueProvider.of(context);

  final socialAuthService = SocialAuthService(
    vkIdService: VkIdAuthService(),
    yandexIdService: YandexIdAuthService(),
  );

  return AuthWM(
    AuthModel(
      repository: scope.repository,
      socialAuthService: socialAuthService,
    ),
    snackController: snackController,
  );
}
```

### 6.2. Model

**Файл:** `lib/features/auth/presentation/screens/auth/auth_model.dart`

```dart
final class AuthModel extends ElementaryModel {
  AuthModel({
    required IAuthRepository repository,
    required this.socialAuthService,
    super.errorHandler,
  }) : _repository = repository;

  final IAuthRepository _repository;
  final SocialAuthService socialAuthService;

  @visibleForTesting
  bool isLoadingVk = false;

  @visibleForTesting
  bool isLoadingYandex = false;

  Future<void> signInWithVk() async {
    isLoadingVk = true;
    try {
      final result = await socialAuthService.signInWithVkId();
      await _repository.socialSignIn(result);
    } on Exception {
      isLoadingVk = false;
      rethrow;
    }
    isLoadingVk = false;
  }

  Future<void> signInWithYandex() async {
    isLoadingYandex = true;
    try {
      final result = await socialAuthService.signInWithYandexId();
      await _repository.socialSignIn(result);
    } on Exception {
      isLoadingYandex = false;
      rethrow;
    }
    isLoadingYandex = false;
  }
}
```

### 6.3. Repository интерфейс

**Файл:** `lib/features/auth/domain/repositories/i_auth_repository.dart`

```dart
abstract interface class IAuthRepository implements IBaseRepository {
  ApiOperation<void> socialSignIn(SocialAuthResult result);
  Stream<AuthState> get authStateChanges;
}
```

### 6.4. Firebase реализация

**Файл:** `lib/features/auth/data/repositories/firebase_auth_repository.dart`

```dart
@Override
ApiOperation<void> socialSignIn(SocialAuthResult result) =>
    makeCall<void, ApiFailure>(() async {
      // Шаг 1: Сохраняем OAuth данные через OAuthService
      final oauthResult = oauth.OAuthResult(
        provider: result.provider == SocialAuthProvider.vk
            ? oauth.OAuthProvider.vk
            : oauth.OAuthProvider.yandex,
        providerToken: result.accessToken,
        providerUserId: result.subject,
        email: result.email,
        phone: result.phone,
        displayName: result.displayName,
      );

      await _oauthService.signInWithOAuth(oauthResult);

      // Шаг 2: Проверяем что пользователь авторизован в Firebase
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw ApiFailure(
          original: Exception('Firebase user not found after OAuth'),
          trace: StackTrace.current,
          message: 'Ошибка авторизации: пользователь не найден',
          statusCode: 500,
        );
      }

      // Шаг 3: Обновляем локальный профиль
      await _syncProfileAfterSocialSignIn(
        result: result,
        firebaseUid: firebaseUser.uid,
      );

      // Шаг 4: Обновляем auth state
      _authStateController.add(AuthState.authenticated);
    });
```

## 7. OAuth Service

**Файл:** `lib/features/auth/data/services/oauth_service.dart`

```dart
enum OAuthProvider {
  vk('vk'),
  yandex('yandex');

  const OAuthProvider(this.name);
  final String name;
}

final class OAuthResult {
  const OAuthResult({
    required this.provider,
    required this.providerToken,
    required this.providerUserId,
    required this.email,
    this.phone,
    this.displayName,
  });

  final OAuthProvider provider;
  final String providerToken;
  final String providerUserId;
  final String email;
  final String? phone;
  final String? displayName;
}
```

### Flow OAuth Service:

1. Сохраняет провайдер токены в `FlutterSecureStorage`
2. Создаёт Firebase Anonymous Auth пользователя
3. Сохраняет данные пользователя в Firestore
4. Возвращает `UserCredential`

### Хранение токенов:

```dart
static const String _kVkTokenKey = 'oauth_vk_access_token';
static const String _kVkIdTokenKey = 'oauth_vk_id_token';
static const String _kYandexTokenKey = 'oauth_yandex_access_token';
static const String _kUserDataKey = 'oauth_user_data';
```

### Сохранение в Firestore:

```dart
await _kvClient.setValue(
  'auth:social:\${oauthResult.provider.name}:\${oauthResult.providerUserId}',
  {
    'uid': firebaseUid,
    'email': oauthResult.email,
    'provider': oauthResult.provider.name,
    'providerUserId': oauthResult.providerUserId,
    'createdAt': now.toIso8601String(),
  },
);

await _kvClient.setValue('auth:user:\$firebaseUid', userData);

final normalizedEmail = oauthResult.email.toLowerCase().trim();
await _kvClient.setValue('auth:email:\$normalizedEmail', {
  'uid': firebaseUid,
  'email': normalizedEmail,
  'provider': oauthResult.provider.name,
  'providerUserId': oauthResult.providerUserId,
});
```

## 8. Запуск в приложении

**Файл:** `lib/runner.dart`

```dart
Future<void> run(Environment env) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChromeUtil.setDefaultSystemUIOverlayStyle();
      await loadAppDotEnv();
      await _runApp(env);
    },
    (error, stacktrace) {
      debugPrint(error.toString());
    },
  );
}
```

## 9. Сборка данных пользователя

### VK ID:

| Поле | Источник |
|------|----------|
| `subject` | `authData.userID` |
| `email` | `userData.email` (fallback: `vk-{userID}@vk.local`) |
| `phone` | `userData.phone` |
| `displayName` | `userData.firstName + userData.lastName` |
| `avatarUrl` | `authData.userData.avatarUrl` |
| `accessToken` | `authData.token` |
| `refreshToken` | `authData.idToken` |

### Yandex ID:

| Поле | Источник |
|------|----------|
| `subject` | `user.id` |
| `email` | `user.defaultEmail` → `user.emails.first` → fallback |
| `phone` | `user.defaultPhone?.number` |
| `displayName` | `user.displayName` → `user.realName` → `user.firstName + user.lastName` → `user.login` |
| `avatarUrl` | `user.defaultPhoto` → `user.photos.first` |
| `accessToken` | `loginResult.token` |

## 10. Обработка ошибок

- `AuthCancelledError` → `SocialAuthCanceledException`
- `AuthOtherError` → `StateError(error.description)`
- Таймаут VK ID → `StateError('VK ID authorization timed out')` (60 секунд)
- `YandexAuthCancelledException` → `SocialAuthCanceledException`
