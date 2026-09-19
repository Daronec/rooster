# Интеграция нативного SDK Сбер ID (App-to-App SSO)

> Полное руководство по добавлению авторизации через нативное приложение Сбербанка (Single Sign-On).

---

## Оглавление

1. [Обзор подхода](#1-обзор-подхода)
2. [Преимущества нативного SDK](#2-преимущества-нативного-sdk)
3. [Подключение нативных SDK](#3-подключение-нативных-sdk)
4. [Настройка Android (Kotlin)](#4-настройка-android-kotlin)
5. [Настройка iOS (Swift)](#5-настройка-ios-swift)
6. [Dart-код для вызова нативных методов](#6-dart-код-для-вызова-нативных-методов)
7. [Использование в UI](#7-использование-в-ui)
8. [Важные замечания](#8-важные-замечания)
9. [Тестирование](#9-тестирование)
10. [Ссылки](#10-ссылки)

---

## 1. Обзор подхода

Использование нативного приложения Сбербанка (App-to-App авторизация) — это **Single Sign-On (SSO)**. Если у пользователя уже установлено приложение Сбера и он там авторизован, ему не нужно вводить логин/пароль — достаточно подтвердить вход (часто через биометрию).

Для этого используется **нативный SDK Сбер ID**, который интегрируется через `MethodChannel`.

### Как это работает

```
Flutter App
    │
    ▼
MethodChannel ('sber_id_auth')
    │
    ├── Android: SberId.login() → нативное приложение Сбера
    └── iOS: SberId.login() → нативное приложение Сбера
    │
    ▼
Нативное приложение Сбера (биометрия / сессия)
    │
    ▼
Access Token → отправка на Backend для валидации
```

---

## 2. Преимущества нативного SDK

| Преимущество | Описание |
|--------------|----------|
| ✅ Удобный UX | Если приложение Сбера установлено, пользователь просто подтверждает вход (Face ID / Touch ID) |
| ✅ Без логина/пароля | Используется существующая сессия в приложении Сбера |
| ✅ Безопасно | Токены генерируются нативным SDK |
| ✅ Быстрее | Не нужно открывать браузер и ждать загрузки страниц |
| ✅ Fallback на браузер | Если приложение Сбера не установлено, SDK автоматически откроет браузер |

---

## 3. Подключение нативных SDK

### Шаг 3.1. Android

Файл: `android/app/build.gradle.kts`

```gradle
dependencies {
    // SDK Сбер ID (версию уточните в документации developer.sber.ru)
    implementation('ru.sber.id:sdk:1.0.0')
}
```

После добавления:
```bash
cd android && ./gradlew clean
```

### Шаг 3.2. iOS

Файл: `ios/Podfile`

```ruby
target 'Runner' do
  # Уже существующие pod-зависимости...
  
  # SDK Сбер ID (версию уточните в документации developer.sber.ru)
  pod 'SberId', '~> 1.0.0'
end
```

После добавления:
```bash
cd ios && pod install
```

### Шаг 3.3. Проверка установки

```bash
cd android && ./gradlew clean
cd ../ios && pod install
cd ..
```

---

## 4. Настройка Android (Kotlin)

Файл: `android/app/src/main/kotlin/com/yourcompany/rooster/MainActivity.kt`

```kotlin
package com.yourcompany.rooster

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ru.sber.id.SberId
import ru.sber.id.SberIdAuthResult

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sber_id_auth"
    private lateinit var sberId: SberId

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Инициализация SDK (Client ID из личного кабинета разработчика)
        sberId = SberId.Builder()
            .setClientId("ВАШ_CLIENT_ID")
            .build()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loginWithSber" -> {
                    loginWithSber(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun loginWithSber(result: MethodChannel.Result) {
        sberId.login(this, object : SberIdAuthResult {
            override fun onSuccess(token: String) {
                runOnUiThread {
                    result.success(token)
                }
            }

            override fun onError(error: String) {
                runOnUiThread {
                    result.error("SBER_ID_ERROR", error, null)
                }
            }

            override fun onCancel() {
                runOnUiThread {
                    result.error("SBER_ID_CANCELLED", "User cancelled", null)
                }
            }
        })
    }
}
```

### Важные моменты для Android

1. **Client ID**: замените `"ВАШ_CLIENT_ID"` на реальный Client ID из [developer.sber.ru](https://developer.sber.ru/).
2. **Поток UI**: все вызовы `result.success/error` должны выполняться в UI-потоке (`runOnUiThread`).
3. **Глобальный экземпляр**: `sberId` инициализируется один раз при запуске `MainActivity`.

---

## 5. Настройка iOS (Swift)

Файл: `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import SberId

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "sber_id_auth"
    private var sberId: SberId?
    private var pendingResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Инициализация SDK (Client ID из личного кабинета разработчика)
        sberId = SberId(clientId: "ВАШ_CLIENT_ID")
        
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "loginWithSber" {
                self?.loginWithSber(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func loginWithSber(result: @escaping FlutterResult) {
        pendingResult = result
        
        sberId?.login(from: self.window?.rootViewController ?? UIViewController()) { [weak self] authResult in
            DispatchQueue.main.async {
                switch authResult {
                case .success(let token):
                    self?.pendingResult?(token)
                case .failure(let error):
                    self?.pendingResult?(FlutterError(
                        code: "SBER_ID_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                case .cancelled:
                    self?.pendingResult?(FlutterError(
                        code: "SBER_ID_CANCELLED",
                        message: "User cancelled",
                        details: nil
                    ))
                }
                self?.pendingResult = nil
            }
        }
    }
    
    // Обработка URL callback (если требуется)
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let sberId = sberId, sberId.canHandle(url) {
            return sberId.handle(url)
        }
        return false
    }
}
```

### Важные моменты для iOS

1. **Client ID**: замените `"ВАШ_CLIENT_ID"` на реальный Client ID.
2. **URL callback**: метод `application(_:open:options:)` обрабатывает Deep Link от SDK (если требуется).
3. **Безопасность**: используйте `weak self` для избежания retain cycles.

---

## 6. Dart-код для вызова нативных методов

Файл: `lib/features/auth/data/sber_auth_service.dart`

```dart
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Сервис авторизации через нативный SDK Сбер ID.
class SberAuthService {
  static const MethodChannel _channel = MethodChannel('sber_id_auth');

  /// Выполнить вход через нативное приложение Сбера.
  ///
  /// Возвращает access-token при успехе, null при отмене или ошибке.
  Future<String?> loginWithSber() async {
    try {
      debugPrint('SberAuthService: initiating login with Sber ID...');
      
      final String? token = await _channel.invokeMethod('loginWithSber');
      
      if (token != null && token.isNotEmpty) {
        debugPrint('SberAuthService: token received (length: ${token.length})');
        
        // TODO: Отправьте токен на ваш Backend для валидации
        // await sendTokenToBackend(token);
        
        return token;
      }
      
      debugPrint('SberAuthService: no token received');
      return null;
    } on PlatformException catch (e) {
      _handlePlatformException(e);
      return null;
    } catch (e) {
      debugPrint('SberAuthService: unexpected error: $e');
      return null;
    }
  }

  /// Проверить, доступен ли нативный SDK Сбер ID.
  Future<bool> isSberIdAvailable() async {
    try {
      final bool? available = await _channel.invokeMethod('isAvailable');
      return available ?? false;
    } catch (_) {
      return false;
    }
  }

  void _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'SBER_ID_CANCELLED':
        debugPrint('SberAuthService: user cancelled authorization');
        break;
      case 'SBER_ID_ERROR':
        debugPrint('SberAuthService: Sber ID error: ${e.message}');
        break;
      default:
        debugPrint('SberAuthService: platform error: ${e.message}');
        break;
    }
  }
}
```

---

## 7. Использование в UI

Файл: `lib/features/auth/presentation/screens/auth/widgets/sber_id_native_sign_in_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/auth/data/sber_auth_service.dart';

/// Кнопка входа через нативное приложение Сбер ID.
class SberIdNativeSignInButton extends StatefulWidget {
  const SberIdNativeSignInButton({super.key});

  @override
  State<SberIdNativeSignInButton> createState() => _SberIdNativeSignInButtonState();
}

class _SberIdNativeSignInButtonState extends State<SberIdNativeSignInButton> {
  final SberAuthService _authService = SberAuthService();
  bool _isLoading = false;

  Future<void> _handleSignIn(BuildContext context) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final token = await _authService.loginWithSber();
      
      if (!mounted) return;
      
      if (token != null) {
        // TODO: Отправить токен на Backend и получить сессию
        // await _authService.exchangeTokenForSession(token);
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _handleSignIn(context),
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.business, size: 20),
      label: Text(
        FlutterI18n.translate(context, 'auth_sign_in_sber'),
      ),
    );
  }
}
```

### Добавление на экран авторизации

Файл: `lib/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart`

```dart
// Добавьте кнопку Sber ID в список кнопок авторизации:
const SberIdNativeSignInButton(),
```

---

## 8. Важные замечания

### 8.1. Fallback на браузер

Если нативное приложение Сбера **не установлено**, SDK автоматически откроет браузер для авторизации через веб-версию Сбер ID. Это обеспечивает бесперебойный UX.

### 8.2. Точные API SDK

Код выше написан на основе типичной структуры нативных SDK. **Обязательно проверьте актуальную документацию Сбер ID** в личном кабинете разработчика:

- Названия классов и методов могут отличаться
- Версии SDK могут быть другими
- Могут быть дополнительные настройки (Deep Links, scopes и т.д.)

### 8.3. Валидация на Backend

Полученный токен **обязательно** нужно отправлять на ваш сервер для:
- Проверки подписи токена
- Получения данных пользователя
- Создания сессии в приложении

### 8.4. Тестирование

Убедитесь, что:
- На тестовом устройстве установлено приложение Сбербанка
- Вы используете правильный Client ID из **тестового** контура
- Настроены правильные Redirect URI

---

## 9. Тестирование

### Сценарии тестирования

| Сценарий | Ожидаемый результат |
|----------|---------------------|
| Вход через Сбера (установлено) | Открывается нативное приложение → биометрия → успех |
| Вход без Сбера (не установлено) | Открывается браузер → веб-авторизация → успех |
| Отмена авторизации | Возврат на экран авторизации, без ошибок |
| Нет сети | Ошибка с предложением повторить |
| Неправильный Client ID | Ошибка конфигурации от SDK |

### Локализация

Файл: `assets/flutter_i18n/ru.json`

```json
{
  "auth_sign_in_sber": "Войти через Сбер ID",
  "auth_sber_error": "Ошибка входа через Сбер ID",
  "auth_sber_unavailable": "Sber ID недоступен на этом устройстве",
  "auth_signing_in": "Вход..."
}
```

Файл: `assets/flutter_i18n/en.json`

```json
{
  "auth_sign_in_sber": "Sign in with Sber ID",
  "auth_sber_error": "Sber ID sign-in error",
  "auth_sber_unavailable": "Sber ID is not available on this device",
  "auth_signing_in": "Signing in..."
}
```

---

## 10. Ссылки

- [Sber Developer Portal](https://developer.sber.ru/)
- [Документация API Сбер ID](https://develop.sber.ru/docs/)
- [Flutter MethodChannel](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Appwrite OAuth2 Documentation](https://appwrite.io/docs/references/3.x.x/#auth)

---

## Сравнение подходов

| Характеристика | OAuth2 (через браузер) | Нативный SDK (App-to-App) |
|----------------|------------------------|---------------------------|
| UX | Переход в браузер | Нативное приложение Сбера |
| Скорость | Медленнее (загрузка браузера) | Быстрее |
| Биометрия | Нет | Да (Face ID / Touch ID) |
| Fallback | — | Автоматически в браузер |
| Сложность | Ниже (только Flutter) | Выше (нужен нативный код) |
| Зависимости | Только Flutter-пакеты | Flutter + нативные SDK |

Рекомендуется реализовать **оба подхода** и выбрать нативный SDK как основной, с fallback на OAuth2.
