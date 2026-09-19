# Интеграция Sber ID через Appwrite OAuth2 (cloud.ru)

> Реализация авторизации через Sber ID с использованием Appwrite как cloud backend.

---

## Оглавление

1. [Архитектура](#1-архитектура)
2. [Что реализовано](#2-что-реализовано)
3. [Настройка в Appwrite Console](#3-настройка-в-appwrite-console)
4. [Native SDK (опционально)](#4-native-sdk-опционально)
5. [Поток авторизации](#5-поток-авторизации)
6. [Тестирование](#6-тестирование)
7. [Ссылки](#7-ссылки)

---

## 1. Архитектура

```
User → Sber ID Button → IAuthGateway.signInWithSberId()
                                      │
                                      ▼
                          AppwriteAuthGatewayImpl
                                      │
                                      ▼
                     Account.createOAuth2Session(
                       provider: OAuthProvider.custom,
                       scopes: 'openid profile email'
                     )
                                      │
                                      ▼
                          Сбер ID OAuth2 Flow
                          (нативное приложение или браузер)
                                      │
                                      ▼
                          Callback → appwrite-callback-rooster://
                                      │
                                      ▼
                          Appwrite обменивает code на сессию
                                      │
                                      ▼
                          Пользователь авторизован ✅
```

### Ключевое преимущество

**Appwrite сам обменивает authorization code на сессию** — не нужен бэкенд.

---

## 2. Что реализовано

### Интерфейсы

| Файл | Изменения |
|------|-----------|
| `lib/features/auth/domain/gateways/i_auth_gateway.dart` | Добавлен `signInWithSberId()` |
| `lib/features/auth/domain/gateways/i_sber_id_gateway.dart` | Добавлен `dispose()` |

### Реализации

| Файл | Изменения |
|------|-----------|
| `lib/features/auth/data/appwrite_auth_gateway_impl.dart` | Реализован `signInWithSberId()` через `createOAuth2Session(provider: .custom)` |
| `lib/features/auth/data/offline_auth_gateway.dart` | Добавлен `signInWithSberId()` (throw CloudAuthUnavailable) |
| `lib/features/auth/data/sber_id_auth_gateway_impl.dart` | Переписан — использует `IAuthGateway` вместо stream-based API |

### UI

| Файл | Изменения |
|------|-----------|
| `lib/features/auth/presentation/screens/auth/widgets/sber_id_sign_in_button.dart` | Использует `IAuthGateway` вместо `SberAuthService` |
| `lib/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart` | Передаёт `authGateway` вместо `sberIdGateway` |
| `lib/features/auth/presentation/screens/auth/auth_wm.dart` | Добавлен `authGateway` геттер |

### DI

| Файл | Изменения |
|------|-----------|
| `lib/features/auth/di/strategies/appwrite_auth_backend_assembly_strategy.dart` | Создаёт `SberIdAuthGatewayImpl` с `authGateway` |

---

## 3. Настройка в Appwrite Console

### Шаг 1: Добавить Custom OAuth2 Provider

1. Откройте [Appwrite Console](https://cloud.appwrite.io/)
2. Выберите проект `rooster`
3. Перейдите в **Auth** → **Providers**
4. Нажмите **Add Provider** → **Custom OAuth2**

### Шаг 2: Заполнить настройки

| Поле | Значение |
|------|----------|
| **Name** | `Sber ID` |
| **Client ID** | `01a05801-7661-7b6a-b4cc-4c03a5628942` (из `.env`) |
| **Client Secret** | `MDFhMDU4MDEtNzY2MS03YjZhLWI0Y2MtNGMwM2E1NjI4OTQyOjMxMjdjMzVlLTBhOTYtNDQ4YS04ZGMxLTM1NGU1MjUxYTYyZQ==` (из `.env`) |
| **Redirect URL** | `appwrite-callback-rooster://oauth` |
| **Authorization URL** | `https://id.sberbank.ru/oauth/authorize` |
| **Token URL** | `https://id.sberbank.ru/oauth/token` |
| **User Info URL** | `https://id.sberbank.ru/oauth/userinfo` |
| **Scope** | `openid profile email` |

### Шаг 3: Зарегистрировать Redirect URI в Сбере

1. Перейдите на [developer.sber.ru](https://developer.sber.ru/)
2. Откройте ваш проект
3. В настройках Sber ID добавьте Redirect URI:
   ```
   appwrite-callback-rooster://oauth
   ```

---

## 4. Native SDK (опционально)

### Android

Файл: `android/app/build.gradle.kts`

```gradle
dependencies {
    // Sber ID SDK — нативный SDK для App-to-App авторизации
    implementation('ru.sberid:sdk:2.0.0')
}
```

Файл: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Intent filter для OAuth callback -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="rooster-auth" android:host="sber-id" />
</intent-filter>
```

### iOS

Файл: `ios/Podfile`

```ruby
pod 'SberId', '~> 2.0.0'
```

Файл: `ios/Runner/Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rooster-auth</string>
        </array>
    </dict>
</array>
```

### Примечание

Native SDK используется **только для UX** — если приложение Сбера установлено, открывается оно (биометрия). Если нет — открывается браузер.

Appwrite сам обрабатывает callback независимо от того, как был получен code.

---

## 5. Поток авторизации

### Полная схема

```
1. Пользователь нажимает "Сбер ID"
   ↓
2. Appwrite.createOAuth2Session(provider: .custom)
   ↓
3. Открывается браузер или приложение Сбера
   ↓
4. Пользователь авторизуется (биометрия / пароль)
   ↓
5. Сбер редиректит на appwrite-callback-rooster://oauth?code=...
   ↓
6. Appwrite перехватывает callback
   ↓
7. Appwrite обменивает code на token на backend (server-to-server)
   ↓
8. Appwrite создаёт сессию для пользователя
   ↓
9. Пользователь авторизован в приложении ✅
```

### Ключевые моменты

- **Appwrite сам обменивает code на token** — не нужен свой бэкенд
- **Server-to-server обмен** — Client Secret не попадает в клиентское приложение
- **Автоматическое создание пользователя** — если пользователя нет в Appwrite, он создаётся

---

## 6. Тестирование

### Сценарии

| Сценарий | Ожидаемый результат |
|----------|---------------------|
| Вход через Сбера (установлено) | Открывается нативное приложение → биометрия → успех |
| Вход без Сбера (не установлено) | Открывается браузер → веб-авторизация → успех |
| Отмена авторизации | Возврат на экран авторизации |
| Неправильный Client ID | Ошибка от Appwrite |

### Проверка

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

## 7. Ссылки

- [Appwrite OAuth2 Documentation](https://appwrite.io/docs/references/current#/account/createAccountOAuth2)
- [Sber Developer Portal](https://developer.sber.ru/)
- [Android SDK Documentation](https://developers.sber.ru/docs/ru/sberid/sdk/androidsdk/connection)
- [iOS SDK Documentation](https://developers.sber.ru/docs/ru/sberid/sdk/iossdk/connection)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
