# Интеграция VK ID и Yandex ID авторизации для мобильных приложений

## Содержание

- [Обзор](#обзор)
- [Архитектура авторизации](#архитектура-авторизации)
- [VK ID SDK](#vk-id-sdk)
  - [Регистрация приложения](#1-регистрация-приложения-в-vk-id)
  - [Интеграция Android](#android-настройка)
  - [Интеграция iOS](#ios-настройка)
  - [Flutter пакет](#flutter-пакет-vk-id)
  - [Использование в коде](#использование-vk-id-в-коде)
- [Yandex ID SDK](#yandex-id-sdk)
  - [Регистрация приложения](#1-регистрация-приложения-в-yandex-oauth)
  - [Интеграция Android](#android-настройка-yandex)
  - [Интеграция iOS](#ios-настройка-yandex)
  - [Flutter пакет](#flutter-пакет-yandex-id)
  - [Использование в коде](#использование-yandex-id-в-коде)
- [OAuth флоу с Firebase](#oauth-флоу-с-firebase)
- [Безопасность](#безопасность)
- [Обработка ошибок](#обработка-ошибок)
- [Тестирование](#тестирование)
- [Ссылки на документацию](#ссылки-на-документацию)

---

## Обзор

Проект использует **Firebase Anonymous Auth** как основу для аутентификации, с интеграцией социальных провайдеров (VK ID, Yandex ID) через OAuth 2.1.

### Архитектура

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  VK ID /     │     │  SocialAuthService│    │  OAuthService    │
│  Yandex ID   │────>│  (social_auth_    │───>│  (oauth_service  │
│  SDK         │     │   service.dart)   │    │   .dart)         │
└──────────────┘     └────────┬─────────┘    └────────┬─────────┘
                              │                       │
                              v                       v
                     ┌──────────────────┐     ┌──────────────────┐
                     │  FlutterSecure   │     │  Firebase Auth   │
                     │  Storage         │     │  (Anonymous)     │
                     └──────────────────┘     └────────┬─────────┘
                                                       │
                                                       v
                                              ┌──────────────────┐
                                              │    Firestore     │
                                              │   (kv_store)     │
                                              └──────────────────┘
```

### Поток авторизации

1. **Пользователь нажимает кнопку входа** (VK ID или Yandex ID)
2. **SocialAuthService** выполняет OAuth через нативный SDK
3. **OAuthService** координирует флоу:
   - Сохраняет OAuth токены в `FlutterSecureStorage`
   - Создаёт Firebase Anonymous Auth пользователя
   - Сохраняет данные пользователя в Firestore
4. **AuthRepository** завершает вход:
   - Генерирует app tokens (accessToken, refreshToken)
   - Сохраняет токены в `FlutterSecureStorage`
   - Создаёт сессию в Firestore
   - Обновляет auth state на `authenticated`

---

## VK ID SDK

### Официальная документация

- **VK ID для мобильных приложений**: https://dev.vk.com/ru/vkid/install-sdk/android
- **VK ID iOS SDK**: https://dev.vk.com/ru/vkid/install-sdk/ios
- **VK ID Flutter SDK (официальный)**: https://id.vk.com/ru/about/business/go/docs/ru/vkid/latest/vk-id/connection/start-integration/flutter/install
- **План интеграции OAuth VK ID**: https://dev.vk.com/ru/vkid/integration-plan

### 1. Регистрация приложения в VK ID

1. Перейдите в [Кабинет разработчика VK](https://dev.vk.com/)
2. Создайте новое приложение или откройте существующее
3. В настройках приложения включите **VK ID** для мобильных платформ
4. Получите следующие данные:
   - `APPID` — ID приложения
   - `CLIENTSECRET` — секретный ключ
5. Укажите bundle identifiers для Android и iOS

### Android настройка

#### pubspec.yaml

```yaml
dependencies:
  vkid_flutter_sdk: ^1.0.3
```

#### android/build.gradle

```groovy
buildscript {
    ext.kotlin_version = '<kotlin_version>'
    repositories {
        // ... другие репозитории
        maven { url("https://artifactory-external.vkpartner.ru/artifactory/vkid-sdk-andorid/") }
    }
}

allprojects {
    repositories {
        // ... другие репозитории
        maven { url("https://artifactory-external.vkpartner.ru/artifactory/vkid-sdk-andorid/") }
    }
}
```

#### android/app/build.gradle

```groovy
android {
    defaultConfig {
        minSdkVersion 21
        
        manifestPlaceholders += [
            VKIDClientID: 'APPID',
            VKIDClientSecret: 'CLIENTSECRET',
            VKIDRedirectHost: 'vk.com',
            VKIDRedirectScheme: 'vk[APPID]'
        ]
    }
}
```

#### android/app/proguard-rules.pro

```proguard
-dontwarn com.my.tracker.**
-dontwarn com.vk.**
-dontwarn kotlinx.parcelize.Parcelize
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn com.google.errorprone.annotations.Immutable
```

### iOS настройка

#### Info.plist

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>vkauthorize-silent</string>
</array>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>auth_callback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>vk123456</string>  <!-- Replace 123456 with your app ID -->
        </array>
    </dict>
</array>

<key>CLIENT_ID</key>
<string>123456</string>  <!-- Replace with your app ID -->
<key>CLIENT_SECRET</key>
<string>XXXXXXXXXXX</string>  <!-- Replace with your client secret -->
```

#### Universal Links (Runner.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:vk.id.auth.example.com</string>
    </array>
</dict>
</plist>
```

#### Минимальная версия iOS

Установите `deployment_target` не ниже **12.0** в `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

### Flutter пакет VK ID

В проекте используется пакет **`vkid_flutter_sdk: ^1.0.3`**

### Использование VK ID в коде

```dart
import 'package:vkid_flutter_sdk/library_vkid.dart';

Future<SocialAuthResult> signInWithVkId() async {
  final vkid = await VKID.getInstance();
  
  final authData = await vkid.authorize(
    params: AuthParamsBuilder().build(),
    onAuth: (authData) {
      // Успешная авторизация
      return authData;
    },
    onError: (error) {
      if (error is AuthCancelledError) {
        throw const SocialAuthCanceledException();
      }
      if (error is AuthOtherError) {
        throw StateError(error.description);
      }
      throw StateError('VK ID authorization failed');
    },
  );

  return SocialAuthResult(
    provider: SocialAuthProvider.vk,
    subject: authData.userID.toString(),
    email: authData.userData.email ?? 'vk-${authData.userID}@vk.local',
    phone: authData.userData.phone.isNotEmpty ? authData.userData.phone : null,
    accessToken: authData.token,
    refreshToken: authData.idToken,
  );
}
```

---

## Yandex ID SDK

### Официальная документация

- **Yandex ID SDK для мобильных приложений**: https://yandex.com/dev/mobileauthsdk
- **Android SDK**: https://yandex.com/dev/mobileauthsdk/android
- **iOS SDK**: https://yandex.com/dev/mobileauthsdk/ios
- **OAuth авторизация**: https://yandex.com/dev/mobileauthsdk/oauth

### 1. Регистрация приложения в Yandex OAuth

1. Перейдите на [oauth.yandex.ru](https://oauth.yandex.ru)
2. Создайте новое приложение или откройте существующее
3. Включите платформу **Мобильные приложения**
4. Укажите bundle identifiers:
   - **iOS Bundle ID**
   - **Android Package Name**
5. Получите `client_id` (32-символьная hex-строка)

### Android настройка

#### pubspec.yaml

```yaml
dependencies:
  yandex_login_sdk: ^1.0.1
```

#### android/app/build.gradle.kts

```kotlin
android {
    defaultConfig {
        manifestPlaceholders["YANDEX_CLIENT_ID"] = "<your_client_id>"
        manifestPlaceholders["YANDEX_OAUTH_HOST"] = "oauth.yandex.ru"
    }
}
```

#### android/app/src/main/kotlin/.../MainActivity.kt

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

### iOS настройка

#### Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>YandexLoginSDK</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yx0123456789abcdef0123456789abcdef</string>
            <!-- "yx" + your client_id -->
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>primaryyandexloginsdk</string>
    <string>secondaryyandexloginsdk</string>
</array>
```

#### SceneDelegate.swift (для Flutter 3+)

```swift
import Flutter
import UIKit
import yandex_login_sdk

class SceneDelegate: FlutterSceneDelegate {
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        var handled = false
        for ctx in URLContexts {
            if YandexLoginSdkPlugin.handle(openURL: ctx.url) {
                handled = true
            }
        }
        if !handled {
            super.scene(scene, openURLContexts: URLContexts)
        }
    }
}
```

#### Минимальная версия iOS

Установите `deployment_target` не ниже **13.0** в `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

### Flutter пакет Yandex ID

В проекте используется пакет **`yandex_login_sdk: ^1.0.1`**

### Использование Yandex ID в коде

```dart
import 'package:yandex_login_sdk/yandex_login_sdk.dart';

Future<SocialAuthResult> signInWithYandexId() async {
  try {
    final loginResult = await YandexLoginSdk.signIn(
      clientId: AppDotenv.yandexIdClientId,
    );
    
    final user = await YandexLoginSdk.getUserInfo(token: loginResult.token);
    final email = user.defaultEmail ??
        (user.emails.isNotEmpty ? user.emails.first : null) ??
        '${user.login.isNotEmpty ? user.login : "yandex-${user.id}"}@yandex.local';

    return SocialAuthResult(
      provider: SocialAuthProvider.yandex,
      subject: user.id,
      email: email,
      phone: user.defaultPhone?.number,
      accessToken: loginResult.token,
    );
  } on YandexAuthCancelledException {
    throw const SocialAuthCanceledException();
  }
}
```

---

## OAuth флоу с Firebase

### Полная архитектура

```
1. Пользователь нажимает кнопку входа
   ↓
2. SocialAuthService.signInWithVkId() / signInWithYandexId()
   ↓
3. Нативный SDK открывает авторизацию
   - Android: нативное приложение Yandex/VK → Chrome Custom Tab → WebView
   - iOS: нативное приложение Yandex/VK → ASWebAuthenticationSession
   ↓
4. Получение SocialAuthResult (token, user info)
   ↓
5. OAuthService.signInWithOAuth(OAuthResult)
   ├─ 5.1. Сохранение токенов в FlutterSecureStorage
   ├─ 5.2. Создание Firebase Anonymous Auth пользователя
   └─ 5.3. Сохранение данных в Firestore
   ↓
6. AuthRepository завершает вход
   ├─ Генерация app tokens (accessToken, refreshToken)
   ├─ Сохранение токенов в FlutterSecureStorage
   ├─ Создание сессии в Firestore
   └─ Обновление auth state на authenticated
```

### Хранение данных

**FlutterSecureStorage** (зашифрованное хранилище):

| Ключ | Описание |
|------|----------|
| `oauth_vk_access_token` | Токен доступа VK |
| `oauth_vk_id_token` | ID токен VK (для будущего использования) |
| `oauth_yandex_access_token` | Токен доступа Yandex |
| `oauth_user_data` | Метаданные пользователя (JSON) |

**Firestore** (коллекция `kv_store`):

| Ключ | Описание |
|------|----------|
| `auth:social:{provider}:{providerUserId}` | Маппинг социальной авторизации |
| `auth:user:{firebaseUid}` | Профиль пользователя |
| `auth:email:{email}` | Маппинг по email (для future email/password link) |
| `session:{sessionId}` | Данные сессии |

**Firebase Auth** (Anonymous):

| Поле | Описание |
|------|----------|
| UID | Уникальный идентификатор пользователя |
| Email | Email пользователя (если доступен) |
| displayName | Отображаемое имя (если доступно) |

---

## Безопасность

### Хранение токенов

- ✅ OAuth токены хранятся в зашифрованном `FlutterSecureStorage`
- ✅ Firebase Anonymous Auth предоставляет временный UID пользователя
- ✅ Данные пользователя хранятся в Firestore с правилами безопасности
- ✅ Токены обновляются автоматически Firebase

### Рекомендации

1. **Никогда не коммитьте** `client_id`, `client_secret` в репозиторий
2. Используйте `.env` файл для хранения конфиденциальных данных
3. Включите правила безопасности Firestore для защиты данных пользователей
4. Используйте HTTPS для всех API запросов
5. Включите двухфакторную аутентификацию для Firebase проекта

---

## Обработка ошибок

### VK ID ошибки

| Код ошибки | Описание |
|------------|----------|
| `initialization_failed` | Ошибка инициализации плагина |
| `auth_cancelled` | Авторизация отменена пользователем |
| `not_initialized` | Плагин не инициализирован |
| `unknown` | Неизвестная ошибка |
| `context_null` | Ошибка получения Context (только Android) |
| `lifecycle_owner_null` | Ошибка получения LifecycleOwner (только Android) |
| `ui_view_controller_null` | Ошибка получения UIViewController (только iOS) |
| `cant_read_client_id` | Ошибка чтения CLIENT_ID (только iOS) |
| `cant_read_client_secret` | Ошибка чтения CLIENT_SECRET (только iOS) |
| `auth_already_in_progress` | Авторизация уже запущена (только iOS) |

### Yandex ID ошибки

| Исключение | Когда возникает |
|------------|-----------------|
| `YandexAuthCancelledException` | Пользователь отменил авторизацию |
| `YandexAuthInProgressException` | Вызов signIn во время другой авторизации |
| `YandexAuthUnsupportedException` | Плагин недоступен на этой платформе |
| `YandexAuthInvalidTokenException` | Токен истёк или отозван (HTTP 401) |
| `YandexAuthException` | Любая другая ошибка SDK/сети |

### Пример обработки ошибок

```dart
// VK ID
try {
  final result = await socialAuthService.signInWithVkId();
  // Успешная авторизация
} on SocialAuthCanceledException {
  // Пользователь отменил авторизацию
} on StateError catch (e) {
  // Ошибка инициализации или конфигурации
}

// Yandex ID
try {
  final result = await socialAuthService.signInWithYandexId();
  // Успешная авторизация
} on SocialAuthCanceledException {
  // Пользователь отменил авторизацию
} on YandexAuthUnsupportedException {
  // Платформа не поддерживается
} catch (e) {
  // Другие ошибки
}
```

---

## Тестирование

### Предварительные требования

1. Убедитесь, что Firebase инициализирован (проверьте `.env` для `FIREBASE_ENABLED=true`)
2. Убедитесь, что VK/Yandex credentials настроены в `.env`
3. Для VK ID: укажите `APPID` и `CLIENTSECRET`
4. Для Yandex ID: укажите `client_id`

### Шаги тестирования

1. Запустите приложение и нажмите кнопки VK/Yandex входа
2. Проверьте `FlutterSecureStorage` на сохранение токенов
3. Проверьте Firebase Console на появление Anonymous Auth пользователей
4. Проверьте Firestore на наличие документов с данными пользователя
5. Проверьте, что auth state обновился на `authenticated`

### Тестирование Yandex ID

```bash
# Запуск тестов
flutter test

# С покрытием
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

### CI/CD

Каждый пуш и pull request проверяет:

1. `dart format --set-exit-if-changed .` — стиль кода
2. `flutter analyze` — статический анализ
3. `flutter test --coverage` — все тесты должны пройти
4. `flutter pub publish --dry-run` — упаковка валидна
5. Сборка example app для Android, iOS и Web

---

## Ссылки на документацию

### VK ID

- [VK ID для мобильных приложений (официальная документация)](https://dev.vk.com/ru/vkid/install-sdk/android)
- [VK ID iOS SDK](https://dev.vk.com/ru/vkid/install-sdk/ios)
- [VK ID Flutter SDK (официальный)](https://id.vk.com/ru/about/business/go/docs/ru/vkid/latest/vk-id/connection/start-integration/flutter/install)
- [План интеграции OAuth VK ID](https://dev.vk.com/ru/vkid/integration-plan)
- [Как работает авторизация VK ID на Flutter](https://id.vk.com/ru/about/business/go/docs/ru/vkid/latest/vk-id/connection/start-integration/how-auth-works/auth-flow-flutter)
- [Пакет vkid_flutter_sdk на Pub](https://pub.dev/packages/vkid_flutter_sdk)

### Yandex ID

- [Yandex ID SDK для мобильных приложений](https://yandex.com/dev/mobileauthsdk)
- [Android SDK](https://yandex.com/dev/mobileauthsdk/android)
- [iOS SDK](https://yandex.com/dev/mobileauthsdk/ios)
- [OAuth авторизация](https://yandex.com/dev/mobileauthsdk/oauth)
- [Пакет yandex_login_sdk на Pub](https://pub.dev/packages/yandex_login_sdk)

### Firebase

- [Firebase Auth — Anonymous Auth](https://firebase.google.com/docs/auth/flutter/anonymous-auth)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Firestore — Cloud Database](https://firebase.google.com/docs/firestore)

### Общие

- [Flutter — Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [OAuth 2.1 спецификация](https://oauth.net/2.1/)
