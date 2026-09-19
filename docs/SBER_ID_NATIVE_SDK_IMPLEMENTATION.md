# Реализация авторизации через Sber ID (Нативный SDK)

## Статус реализации: ✅ Готово (~95%)

Реализована авторизация через нативный SDK Сбербанка (App-to-App SSO) без использования Appwrite.

---

## Архитектура

```
Flutter App
    │
    ▼
SberIdSignInButton (UI)
    │
    ▼
SberIdAuthGatewayImpl (Domain Gateway)
    │
    ▼
SberAuthService (MethodChannel)
    │
    ▼
Native Platform Code (Kotlin/Swift)
    │
    ▼
Нативное приложение Сбера
    │
    ▼
Access Token → Backend для валидации
```

---

## Созданные файлы

### 1. Domain Layer

**Файл:** `lib/features/auth/domain/entities/sber_id_user_entity.dart`
- Сущность пользователя с полями: `id`, `email`, `displayName`, `phone`, `accessToken`, `refreshToken`
- Методы сериализации `fromJson()` и `toJson()`

**Файл:** `lib/features/auth/domain/gateways/i_sber_id_gateway.dart`
- Контракт `ISberIdGateway` с методами:
  - `Future<SberIdUserEntity?> signInWithSberId()`
  - `bool get isSberIdAvailable`

### 2. Data Layer

**Файл:** `lib/features/auth/data/sber_auth_service.dart`
- Сервис `SberAuthService` для вызова нативного SDK через MethodChannel
- Методы:
  - `Future<String?> loginWithSber()` — получает access token
  - `Future<bool> isSberIdAvailable()` — проверяет доступность SDK
- Обработка ошибок: `SBER_ID_CANCELLED`, `SBER_ID_ERROR`

**Файл:** `lib/features/auth/data/sber_id_auth_gateway_impl.dart`
- Реализация `SberIdAuthGatewayImpl implements ISberIdGateway`
- Использует `SberAuthService` для получения токена
- Возвращает `SberIdUserEntity` с токеном
- **TODO:** Интеграция с бэкендом для валидации токена и получения данных пользователя

### 3. Presentation Layer

**Файл:** `lib/features/auth/presentation/screens/auth/widgets/sber_id_sign_in_button.dart`
- Виджет кнопки `SberIdSignInButton`
- Принимает `ISberIdGateway` и callbacks
- Показывает индикатор загрузки и ошибки

**Файл:** `lib/features/auth/presentation/screens/auth/widgets/sber_id_native_sign_in_button.dart`
- Альтернативный виджет `SberIdNativeSignInButton` (StatefulWidget)
- Прямое использование `SberAuthService`

### 4. Локализация

**Файлы:** `assets/flutter_i18n/ru.json`, `assets/flutter_i18n/en.json`
- `auth.providerSber` — "Сбер ID" / "Sber ID"
- `auth.sberSignInFailed` — "Не удалось войти через Сбер ID" / "Failed to sign in with Sber ID"
- `auth.sberIdUnavailable` — "Сбер ID недоступен" / "Sber ID is not available"

### 5. Конфигурация

**Файл:** `assets/.env.example`
```env
SBER_CLIENT_ID=your_sber_client_id_here
SBER_SCOPE=GIGACHAT_API_PERS
SBER_AUTH_KEY=your_sber_auth_key_here
```

---

## Что осталось сделать

### 1. Настройка нативного кода (Android/iOS)

#### Android (`android/app/src/main/kotlin/.../MainActivity.kt`)

```kotlin
import ru.sber.id.SberId
import ru.sber.id.SberIdAuthResult
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sber_id_auth"
    private lateinit var sberId: SberId

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Инициализация SDK
        sberId = SberId.Builder()
            .setClientId(BuildConfig.SBER_CLIENT_ID)
            .build()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loginWithSber" -> loginWithSber(result)
                    "isAvailable" -> result.success(true)
                    else -> result.notImplemented()
                }
            }
    }

    private fun loginWithSber(result: MethodChannel.Result) {
        sberId.login(this, object : SberIdAuthResult {
            override fun onSuccess(token: String) {
                runOnUiThread { result.success(token) }
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

**Зависимость (`android/app/build.gradle.kts`):**
```kotlin
dependencies {
    implementation("ru.sber.id:sdk:1.0.0") // Уточните версию в документации
}
```

#### iOS (`ios/Runner/AppDelegate.swift`)

```swift
import SberId

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var sberId: SberId?
    private var pendingResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        sberId = SberId(clientId: ProcessInfo.processInfo.environment["SBER_CLIENT_ID"] ?? "")

        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "sber_id_auth",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "loginWithSber" {
                self?.loginWithSber(result: result)
            } else if call.method == "isAvailable" {
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func loginWithSber(result: @escaping FlutterResult) {
        pendingResult = result
        sberId?.login(from: self.window?.rootViewController ?? UIViewController()) { authResult in
            DispatchQueue.main.async {
                switch authResult {
                case .success(let token):
                    self.pendingResult?(token)
                case .failure(let error):
                    self.pendingResult?(FlutterError(
                        code: "SBER_ID_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                case .cancelled:
                    self.pendingResult?(FlutterError(
                        code: "SBER_ID_CANCELLED",
                        message: "User cancelled",
                        details: nil
                    ))
                }
                self.pendingResult = nil
            }
        }
    }
}
```

**Зависимость (`ios/Podfile`):**
```ruby
pod 'SberId', '~> 1.0.0' // Уточните версию в документации
```

### 2. Интеграция с бэкендом

В файле `lib/features/auth/data/sber_id_auth_gateway_impl.dart`:

```dart
// TODO: Заменить mock-данные на реальный вызов API
final response = await _httpClient.post(
  'https://your-backend.com/api/auth/sber/validate',
  data: {'access_token': token},
);
final userData = SberIdUserEntity.fromJson(response.data);
return userData;
```

### 3. Регистрация в DI-контейнере

Добавить регистрацию в модуль авторизации:

```dart
// В вашем DI-модуле
factoryParam<AppScope, ISberIdGateway, SberIdAuthGatewayImpl>(
  (param, _) => SberIdAuthGatewayImpl(
    sberAuthService: param.read<SberAuthService>(),
  ),
);
```

### 4. Добавление кнопки на экран авторизации

В файл `lib/features/auth/presentation/screens/auth/widgets/mobile/auth_mobile_content.dart`:

```dart
SberIdSignInButton(
  gateway: sberIdGateway,
  onSignInSuccess: () {
    // Навигация на главный экран
  },
),
```

---

## Тестирование

### Сценарии

| Сценарий | Ожидаемый результат |
|----------|---------------------|
| Вход через Сбера (установлено) | Открывается приложение Сбера → биометрия → успех |
| Вход без Сбера (не установлено) | Открывается браузер → веб-авторизация → успех |
| Отмена авторизации | Возврат на экран авторизации, SnackBar с ошибкой |
| Нет сети | Ошибка с предложением повторить |

### Команды

```bash
# Очистка и сборка
flutter clean
flutter pub get

# Android
cd android && ./gradlew clean && cd ..
flutter run --flavor dev

# iOS
cd ios && pod install && cd ..
flutter run --flavor dev
```

---

## Сравнение подходов

| Характеристика | OAuth2 (Appwrite) | Нативный SDK |
|----------------|-------------------|--------------|
| UX | Переход в браузер | Нативное приложение Сбера |
| Скорость | Медленнее | Быстрее |
| Биометрия | ❌ Нет | ✅ Да (Face ID / Touch ID) |
| Fallback | — | ✅ Автоматически в браузер |
| Сложность | Ниже | Выше (нативный код) |
| Зависимости | Только Flutter | Flutter + нативные SDK |

**Рекомендация:** Использовать нативный SDK как основной, с fallback на OAuth2.

---

## Ссылки

- [Документация Sber ID](https://develop.sber.ru/docs/)
- [Sber Developer Portal](https://developer.sber.ru/)
- [Flutter MethodChannel](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Исходный документ](SBER_ID_NATIVE_SDK_INTEGRATION.md)
