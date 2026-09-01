# Интеграция Sber ID (SberBank) в Rooster

> Полное руководство по добавлению авторизации через Sber ID в Flutter-приложение Rooster.

---

## Оглавление

1. [Обзор](#1-обзор)
2. [Регистрация в экосистеме Sber](#2-регистрация-в-экосистеме-sber)
3. [Настройка OAuth в Sber ID](#3-настройка-oauth-в-sber-id)
4. [Подготовка Flutter-проекта](#4-подготовка-flutter-проекта)
5. [Реализация Sber ID Auth Gateway](#5-реализация-sber-id-auth-gateway)
6. [Интеграция с Appwrite OAuth2](#6-интеграция-с-appwrite-oauth2)
7. [UI: кнопка Sber ID на экране авторизации](#7-ui-кнопка-sber-id-на-экране-авторизации)
8. [Локализация](#8-локализация)
9. [Тестирование](#9-тестирование)
10. [Критерии приёмки](#10-критерии-приёмки)
11. [Ссылки](#11-ссылки)

---

## 1. Обзор

Sber ID — это сервис единого входа (Single Sign-On) от Сбера, основанный на OAuth 2.0 / OpenID Connect.

### Что мы делаем

1. Регистрируем приложение в [Sber Developer Portal](https://developer.sber.ru/).
2. Настраиваем OAuth-провайдер в Appwrite Console.
3. Создаём `SberIdAuthGatewayImpl`, реализующий `ISberIdGateway`.
4. Добавляем кнопку Sber ID на экран авторизации.
5. Локализуем текст (ru / en).

### Архитектурный подход

Приложение уже поддерживает OAuth-провайдеры через Appwrite:

```
IAuthGateway (контракт)
  ├── AppwriteAuthGatewayImpl (Google, Apple, email/password)
  ├── HuaweiAuthGatewayImpl (HUAWEI ID)
  └── SberIdAuthGatewayImpl (Sber ID) ← новое
```

Sber ID работает как OAuth2-провайдер в Appwrite. Нам нужно:
- Настроить кастомный OAuth2 провайдер в Appwrite Console.
- Вызвать `createOAuth2Session` с `OAuthProvider.custom`.
- Перехватить callback через `app_links`.

---

## 2. Регистрация в экосистеме Sber

### Шаг 2.1. Создание проекта

1. Перейдите на [developer.sber.ru](https://developer.sber.ru/).
2. Войдите под аккаунтом разработчика.
3. Создайте новый проект / приложение.
4. Заполните данные:
   - **Название**: `Rooster`
   - **Описание**: Task Manager
   - **Логотип**: загрузите иконку приложения
   - **Описание**: приложение для управления задачами

### Шаг 2.2. Подключение Sber ID

1. В настройках проекта включите сервис **Sber ID**.
2. Укажите типы клиентов: **Mobile / Web**.

### Шаг 2.3. Получение Client ID и Secret

После включения Sber ID вы получите:
- **Client ID** — публичный идентификатор приложения
- **Client Secret** — секретный ключ (для backend-обмена кодом)

> Сохраните эти значения — они понадобятся для конфигурации Appwrite и `.env`.

---

## 3. Настройка OAuth в Sber ID

### Шаг 3.1. Redirect URI (Callback URL)

Для мобильного приложения используйте deep link:

```
appwrite-callback-rooster://oauth
```

Зарегистрируйте этот URI в настройках Sber ID как **Redirect URI**.

### Шаг 3.2. Scopes

Стандартные scopes для Sber ID:

| Scope | Описание |
|-------|----------|
| `openid` | OpenID Connect (обязательно) |
| `profile` | Имя пользователя |
| `email` | Email пользователя |

Минимальный набор: `openid profile email`.

### Шаг 3.3. Endpoints Sber ID

| Endpoint | URL |
|----------|-----|
| Authorization | `https://id.sberbank.ru/auth/authorize` |
| Token | `https://id.sberbank.ru/auth/token` |
| User Info | `https://id.sberbank.ru/auth/userinfo` |
| Logout | `https://id.sberbank.ru/auth/revoke` |

---

## 4. Подготовка Flutter-проекта

### Шаг 4.1. Зависимости

Файл: `pubspec.yaml`

```yaml
dependencies:
  # Уже есть — дополнительные не требуются:
  app_links: ^7.0.0        # Для перехвата deep link callback
  appwrite: 23.0.0         # Для OAuth2 сессии
```

Приложение уже содержит `app_links` и `appwrite: 23.0.0`. Дополнительные пакеты не требуются.

### Шаг 4.2. Android настройка

Файл: `android/app/src/main/AndroidManifest.xml`

Добавьте intent-filter для deep link callback:

```xml
<activity
    android:name=".MainActivity"
    ...>
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="appwrite-callback-rooster"
            android:host="oauth" />
    </intent-filter>
</activity>
```

### Шаг 4.3. iOS настройка

Файл: `ios/Runner/Info.plist`

Добавьте URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>appwrite-callback-rooster</string>
        </array>
    </dict>
</array>
```

### Шаг 4.4. Переменные окружения

Файл: `.env`

```env
# Sber ID OAuth
SBER_ID_CLIENT_ID=your_sber_client_id
SBER_ID_AUTHORIZATION_URL=https://id.sberbank.ru/auth/authorize
SBER_ID_TOKEN_URL=https://id.sberbank.ru/auth/token
SBER_ID_USER_INFO_URL=https://id.sberbank.ru/auth/userinfo
SBER_ID_SCOPES=openid profile email
```

---

## 5. Реализация Sber ID Auth Gateway

### Шаг 5.1. Сущность пользователя Sber ID

Файл: `lib/features/auth/domain/entities/sber_id_user_entity.dart`

```dart
/// Сущность пользователя, полученная через Sber ID.
class SberIdUserEntity {
  const SberIdUserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.phone,
  });

  /// Уникальный идентификатор Sber ID.
  final String id;

  /// Email пользователя.
  final String? email;

  /// Отображаемое имя.
  final String? displayName;

  /// Телефон.
  final String? phone;

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'phone': phone,
  };

  factory SberIdUserEntity.fromJson(Map<String, Object?> json) {
    return SberIdUserEntity(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
```

### Шаг 5.2. Контракт Sber ID Gateway

Файл: `lib/features/auth/domain/gateways/i_sber_id_gateway.dart`

```dart
import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';

/// Контракт для авторизации через Sber ID.
abstract interface class ISberIdGateway {
  /// Начать OAuth-флоу Sber ID.
  Future<SberIdUserEntity?> signInWithSberId();

  /// Проверить, доступен ли Sber ID на устройстве.
  bool get isSberIdAvailable;
}
```

### Шаг 5.3. Реализация Sber ID Gateway

Файл: `lib/features/auth/data/sber_id_auth_gateway_impl.dart`

```dart
import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:appwrite/models.dart' as aw_models;
import 'package:flutter/foundation.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';
import 'package:rooster/integration/appwrite/i_appwrite_session_storage.dart';

/// Реализация авторизации через Sber ID с использованием Appwrite OAuth2.
final class SberIdAuthGatewayImpl implements ISberIdGateway {
  SberIdAuthGatewayImpl({
    required Client client,
    required Account account,
    required AppwriteEnvConfig envConfig,
    required IAppwriteSessionStorage sessionStorage,
  }) : _client = client,
       _account = account,
       _envConfig = envConfig,
       _sessionStorage = sessionStorage;

  final Client _client;
  final Account _account;
  final AppwriteEnvConfig _envConfig;
  final IAppwriteSessionStorage _sessionStorage;

  @override
  bool get isSberIdAvailable => true;

  @override
  Future<SberIdUserEntity?> signInWithSberId() async {
    try {
      // Используем Appwrite OAuth2 для Sber ID (Custom provider).
      final session = await _account.createOAuth2Session(
        provider: appwrite_enums.OAuthProvider.custom,
        success: _envConfig.oauthSuccessUrl,
        failure: _envConfig.oauthFailureUrl,
        scopes: 'openid profile email',
      );

      // Сохраняем сессию.
      await _sessionStorage.writeSessionSecret(session.secret);
      _client.setSession(session.secret);

      // Получаем данные пользователя.
      final user = await _account.get();
      return SberIdUserEntity(
        id: user.$id,
        email: user.email.trim().isEmpty ? null : user.email.trim(),
        displayName: user.name.trim().isEmpty ? null : user.name.trim(),
        phone: user.phone.trim().isEmpty ? null : user.phone.trim(),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Sber ID auth failed: $e');
      }
      return null;
    }
  }
}
```

---

## 6. Интеграция с Appwrite OAuth2

### Шаг 6.1. Настройка Custom Provider в Appwrite

1. Откройте **Appwrite Console** → **Auth** → **Providers**.
2. Нажмите **Add Provider** → **Custom OAuth2**.
3. Заполните:

| Поле | Значение |
|------|----------|
| Name | `Sber ID` |
| Client ID | из developer.sber.ru |
| Client Secret | из developer.sber.ru |
| Redirect URL | `appwrite-callback-rooster://oauth` |
| Authorization URL | `https://id.sberbank.ru/auth/authorize` |
| Token URL | `https://id.sberbank.ru/auth/token` |
| User Info URL | `https://id.sberbank.ru/auth/userinfo` |
| Scope | `openid profile email` |

### Шаг 6.2. Использование в коде

```dart
// В AppwriteAuthGatewayImpl или отдельном SberIdAuthGatewayImpl:
await _account.createOAuth2Session(
  provider: appwrite_enums.OAuthProvider.custom,
  success: _envConfig.oauthSuccessUrl,
  failure: _envConfig.oauthFailureUrl,
  scopes: 'openid profile email',
);
```

---

## 7. UI: кнопка Sber ID на экране авторизации

### Шаг 7.1. Виджет кнопки Sber ID

Файл: `lib/features/auth/presentation/screens/auth/widgets/sber_id_sign_in_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';

/// Кнопка входа через Sber ID.
class SberIdSignInButton extends StatelessWidget {
  const SberIdSignInButton({
    required this.gateway,
    super.key,
  });

  final ISberIdGateway gateway;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: gateway.isSberIdAvailable
          ? () => _handleSignIn(context)
          : null,
      icon: const Icon(Icons.business),
      label: Text(
        FlutterI18n.translate(context, 'auth_sign_in_sber'),
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final user = await gateway.signInWithSberId();
      if (user == null) {
        // Показать ошибку
      }
    } on Exception catch (e) {
      // Показать ошибку
    }
  }
}
```

### Шаг 7.2. Добавление на экран авторизации

Файл: `lib/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart`

Добавьте кнопку Sber ID в список кнопок авторизации:

```dart
SberIdSignInButton(gateway: sberIdGateway),
```

---

## 8. Локализация

### Файл: `assets/flutter_i18n/ru.json`

```json
{
  "auth_sign_in_sber": "Войти через Сбер ID",
  "auth_sber_error": "Ошибка входа через Сбер ID",
  "auth_sber_unavailable": "Sber ID недоступен на этом устройстве"
}
```

### Файл: `assets/flutter_i18n/en.json`

```json
{
  "auth_sign_in_sber": "Sign in with Sber ID",
  "auth_sber_error": "Sber ID sign-in error",
  "auth_sber_unavailable": "Sber ID is not available on this device"
}
```

---

## 9. Тестирование

### Шаг 9.1. Unit-тесты

Файл: `test/features/auth/sber_id_auth_gateway_impl_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';

void main() {
  group('SberIdAuthGatewayImpl', () {
    test('isSberIdAvailable returns true on supported platforms', () {
      // Тест доступности на Android/iOS
    });

    test('signInWithSberId returns user on successful auth', () {
      // Мокаем Appwrite Client и Account
    });

    test('signInWithSberId returns null on failure', () {
      // Тестируем обработку ошибки
    });
  });
}
```

### Шаг 9.2. Сценарии тестирования

| Сценарий | Ожидаемый результат |
|----------|---------------------|
| Вход через Sber ID на Android | Переход в браузер Sber ID → callback → авторизация успешна |
| Вход через Sber ID на iOS | Аналогично Android |
| Отмена авторизации | Возврат на экран авторизации без ошибок |
| Нет сети во время авторизации | Ошибка с предложением повторить |
| Sber ID не настроен в Appwrite | Ошибка конфигурации |

---

## 10. Критерии приёмки

- [ ] Sber ID зарегистрирован в Appwrite как Custom OAuth2 Provider.
- [ ] Кнопка «Войти через Сбер ID» отображается на экране авторизации.
- [ ] При нажатии открывается браузер Sber ID для авторизации.
- [ ] После успешной авторизации пользователь попадает в приложение.
- [ ] Данные пользователя (email, имя) корректно отображаются в профиле.
- [ ] Выход из Sber ID сессии работает корректно.
- [ ] Локализация (ru / en) для всех элементов Sber ID.
- [ ] Тесты на Android и iOS проходят успешно.

---

## 11. Ссылки

- [Sber Developer Portal](https://developer.sber.ru/)
- [Sber ID API Documentation](https://develop.sber.ru/docs/education/self/intro)
- [Appwrite OAuth2 Documentation](https://appwrite.io/docs/references/3.x.x/#auth)
- [app_links Package](https://pub.dev/packages/app_links)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/deep-linking)
