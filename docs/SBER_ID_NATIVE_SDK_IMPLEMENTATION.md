# Интеграция нативного SDK Сбер ID (App-to-App SSO) — Финальная реализация

> На основе официальной документации: https://developers.sber.ru/docs/ru/sberid/sdk/androidsdk/connection

---

## Оглавление

1. [Обзор](#1-обзор)
2. [Архитектура](#2-архитектура)
3. [Что реализовано](#3-что-реализовано)
4. [Native-часть](#4-native-часть)
5. [Flutter-часть](#5-flutter-часть)
6. [Настройка Client ID](#6-настройка-client-id)
7. [Тестирование](#7-тестирование)
8. [Ссылки](#8-ссылки)

---

## 1. Обзор

Использование нативного приложения Сбербанка (App-to-App авторизация) — это **Single Sign-On (SSO)**. Если у пользователя уже установлено приложение Сбера и он там авторизован, ему не нужно вводить логин/пароль — достаточно подтвердить вход (часто через биометрию).

### Ключевые отличия от OAuth2 через браузер

| Аспект | OAuth2 URL | Native SDK |
|--------|------------|------------|
| Авторизация | Формирование URL + браузер | `SberId.login()` |
| Callback | Intent/URL parsing | Callback из SDK |
| Fallback | Всегда браузер | SDK сам выбирает (app → browser) |
| Биометрия | Нет (веб-форма) | Да (Face ID / Touch ID) |
| UX | Переход в браузер | Нативное приложение Сбера |

---

## 2. Архитектура

```
Flutter App
    │
    ▼
SberIdNativeSignInButton.onPressed()
    │
    ▼
SberAuthService.startLogin()
    │
    ▼
MethodChannel ('com.rooster.app/sber_auth') → 'startLogin'
    │
    ├── Android: SberId.login() → нативное приложение Сбера
    └── iOS: SberId.login() → нативное приложение Сбера
    │
    ▼
Нативное приложение Сбера (биометрия / сессия)
    │
    ▼
SberIdLoginCallback.onSuccess(code) / SberId.login callback
    │
    ▼
EventChannel → Flutter Stream<SberAuthResult>
    │
    ▼
SberAuthSuccess(code) → Backend exchange code for token
```

---

## 3. Что реализовано

### Android

| Файл | Изменения |
|------|-----------|
| `android/app/build.gradle.kts` | Добавлена зависимость `ru.sberid:sdk:2.0.0` |
| `android/app/src/main/AndroidManifest.xml` | Добавлен `intent-filter` для `rooster-auth://sber-id` |
| `android/app/src/main/kotlin/.../MainActivity.kt` | `SberId.init()` + `SberId.login()` с `SberIdLoginCallback`, MethodChannel + EventChannel |

### iOS

| Файл | Изменения |
|------|-----------|
| `ios/Podfile` | Добавлен pod `SberId ~> 2.0.0` |
| `ios/Runner/Info.plist` | Добавлен URL scheme `rooster-auth`, `LSApplicationQueriesSchemes`, `SberClientId` |
| `ios/Runner/AppDelegate.swift` | `SberId.configure()` + `SberId.login()`, MethodChannel + EventChannel, URL handling |

### Flutter

| Файл | Изменения |
|------|-----------|
| `lib/features/auth/data/sber_auth_service.dart` | `initialize()` читает `SBER_CLIENT_ID` из `.env`, MethodChannel + EventChannel |
| `lib/features/auth/data/sber_id_auth_gateway_impl.dart` | Stream-based API с `Completer`, обработка success/error/cancel |
| `lib/features/auth/presentation/.../sber_id_native_sign_in_button.dart` | UI-кнопка с подпиской на stream |
| `lib/features/auth/di/.../appwrite_auth_backend_assembly_strategy.dart` | Создание и инициализация `SberAuthService` |
| `lib/features/auth/domain/gateways/i_sber_id_gateway.dart` | Добавлен `dispose()` |
| `lib/features/profile/data/noop_sber_id_gateway_impl.dart` | Добавлен `dispose()` |
| `assets/flutter_i18n/ru.json` | Добавлено `auth.userCancelled` |
| `assets/flutter_i18n/en.json` | Добавлено `auth.userCancelled` |

---

## 4. Native-часть

### Android (MainActivity.kt)

**Импорты SDK:**
```kotlin
import ru.sberid.SberId
import ru.sberid.SberIdError
import ru.sberid.SberIdLoginCallback
```

**Инициализация:**
```kotlin
SberId.init(
    context = this,
    clientId = clientId,
    scope = scope,
    state = "rooster_sber_state"
)
```

**Авторизация:**
```kotlin
SberId.login(this, object : SberIdLoginCallback {
    override fun onSuccess(code: String) {
        // Authorization code для обмена на токен
    }
    
    override fun onError(error: SberIdError) {
        // Обработка ошибки
    }
    
    override fun onCancel() {
        // Пользователь отменил вход
    }
})
```

**Каналы:**
- `MethodChannel` (`com.rooster.app/sber_auth`) — `initSberSdk`, `startLogin`, `isAvailable`
- `EventChannel` (`com.rooster.app/sber_auth/auth_events`) — `onSberAuthSuccess`, `onSberAuthError`

### iOS (AppDelegate.swift)

**Импорты SDK:**
```swift
import SberId
```

**Инициализация:**
```swift
SberId.configure(
    clientId: clientId,
    scope: scope,
    state: "rooster_sber_state"
)
```

**Авторизация:**
```swift
SberId.login(from: viewController) { authResult in
    switch authResult {
    case .success(let code):
        // Authorization code
    case .failure(let error):
        // Ошибка
    case .cancelled:
        // Отмена
    }
}
```

**URL Handling:**
- `application(_:open:options:)` — для iOS < 13
- `application(_:continue:restorationHandler:)` — для iOS 13+ (Universal Links)

---

## 5. Flutter-часть

### SberAuthService

```dart
class SberAuthService {
  static const MethodChannel _channel = MethodChannel('com.rooster.app/sber_auth');
  
  // Инициализация — передаёт CLIENT_ID из .env в нативную часть
  Future<void> initialize() async {
    final clientId = dotenv.env['SBER_CLIENT_ID'] ?? '';
    await _channel.invokeMethod('initSberSdk', {
      'clientId': clientId,
      'scope': 'openid profile',
    });
  }
  
  // Запуск OAuth-флоу
  Future<bool> startLogin() async;
  
  // Stream результатов авторизации
  Stream<SberAuthResult> get authStream;
}

// Результаты
sealed class SberAuthResult {}
class SberAuthSuccess extends SberAuthResult { final String code; }
class SberAuthFailure extends SberAuthResult { final String error, message; }
```

### SberIdAuthGatewayImpl

```dart
Future<SberIdUserEntity?> signInWithSberId() async {
  final completer = Completer<SberIdUserEntity?>();
  
  _authSubscription = _sberAuthService.authStream.listen((result) {
    switch (result) {
      case SberAuthSuccess(:final code):
        // TODO: Обменять code на токен на бэкенде
        final user = SberIdUserEntity(
          id: 'sber_user_${DateTime.now().millisecondsSinceEpoch}',
          accessToken: code,
        );
        completer.complete(user);
        
      case SberAuthFailure(:final error):
        completer.complete(null);
    }
  });
  
  await _sberAuthService.startLogin();
  return await completer.future.timeout(Duration(minutes: 5));
}
```

---

## 6. Настройка Client ID

`SBER_CLIENT_ID` уже есть в `.env`:
```env
SBER_CLIENT_ID=01a05801-7661-7b6a-b4cc-4c03a5628942
```

### Android

Читается из `local.properties`:
```properties
sber.client.id=01a05801-7661-7b6a-b4cc-4c03a5628942
```

Или передаётся через MethodChannel из Flutter (`SberAuthService.initialize()`).

### iOS

Файл: `ios/Runner/Info.plist`
```xml
<key>SberClientId</key>
<string>01a05801-7661-7b6a-b4cc-4c03a5628942</string>
```

### Redirect URI

Зарегистрируйте в [developer.sber.ru](https://developer.sber.ru/):
```
rooster-auth://sber-id
```

---

## 7. Тестирование

### Сценарии

| Сценарий | Ожидаемый результат |
|----------|---------------------|
| Вход через Сбера (установлено) | Открывается нативное приложение → биометрия → успех |
| Вход без Сбера (не установлено) | Открывается браузер → веб-авторизация → успех |
| Отмена авторизации | Возврат на экран авторизации, сообщение "Вход отменён" |
| Нет сети | Ошибка с предложением повторить |

### Проверка нативных частей

**Android:**
```bash
# Проверка intent-filter
adb shell dumpsys package | grep -A 5 "rooster-auth"
```

**iOS:**
```bash
# Проверка URL schemes
plutil -p ios/Runner/Info.plist | grep -A 5 "CFBundleURLTypes"
```

---

## 8. Ссылки

- [Android SDK Documentation](https://developers.sber.ru/docs/ru/sberid/sdk/androidsdk/connection)
- [iOS SDK Documentation](https://developers.sber.ru/docs/ru/sberid/sdk/iossdk/connection)
- [Developer Portal](https://developer.sber.ru/)
- [Flutter MethodChannel](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
