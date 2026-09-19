# Анализ SDK Сбер ID — Реализация

> На основе официальной документации: https://developers.sber.ru/docs/ru/sberid/sdk/androidsdk/connection

---

## Ключевые выводы из документации

### Android SDK

**Подключение:**
```gradle
dependencies {
    implementation 'ru.sberid:sdk:2.0.0'
}
```

**Инициализация:**
```kotlin
SberId.init(
    context = this,
    clientId = "YOUR_CLIENT_ID",
    scope = "openid profile",
    state = "random_state"
)
```

**Авторизация:**
```kotlin
SberId.login(activity = this, callback = object : SberIdLoginCallback {
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

### iOS SDK

**Подключение:**
```ruby
pod 'SberId', '~> 2.0.0'
```

**Инициализация:**
```swift
SberId.configure(
    clientId: "YOUR_CLIENT_ID",
    scope: "openid profile",
    state: "random_state"
)
```

**Авторизация:**
```swift
SberId.login(from: viewController) { result in
    switch result {
    case .success(let code):
        // Authorization code
    case .failure(let error):
        // Ошибка
    case .cancelled:
        // Отмена
    }
}
```

---

## Обновлённая реализация

### Android (MainActivity.kt)

```kotlin
package ru.aronets.rooster

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import ru.sberid.SberId
import ru.sberid.SberIdError
import ru.sberid.SberIdLoginCallback

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "com.rooster.app/sber_auth"
    private val EVENT_CHANNEL = "com.rooster.app/sber_auth/auth_events"
    private var flutterEngineRef: FlutterEngine? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleAuthIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleAuthIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineRef = flutterEngine

        // MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initSberSdk" -> {
                        val clientId = call.argument<String>("clientId") ?: ""
                        val scope = call.argument<String>("scope") ?: "openid profile"
                        
                        if (clientId.isNotEmpty()) {
                            // Инициализация нативного SDK
                            SberId.init(
                                context = this,
                                clientId = clientId,
                                scope = scope,
                                state = "rooster_sber_state"
                            )
                        }
                        result.success(true)
                    }
                    "startLogin" -> {
                        // Запуск нативного SDK login
                        SberId.login(this, object : SberIdLoginCallback {
                            override fun onSuccess(code: String) {
                                sendEventToFlutter("onSberAuthSuccess", mapOf("code" to code))
                                result.success(true)
                            }
                            
                            override fun onError(error: SberIdError) {
                                sendEventToFlutter("onSberAuthError", mapOf(
                                    "error" to error.code.toString(),
                                    "message" to error.message
                                ))
                                result.error("SBER_SDK_ERROR", error.message, null)
                            }
                            
                            override fun onCancel() {
                                sendEventToFlutter("onSberAuthError", mapOf(
                                    "error" to "SBER_ID_CANCELLED",
                                    "message" to "User cancelled"
                                ))
                                result.error("SBER_ID_CANCELLED", "User cancelled", null)
                            }
                        })
                    }
                    "isAvailable" -> {
                        // Проверяем наличие приложения СберБанк Онлайн
                        val available = isSberAppInstalled()
                        result.success(available)
                    }
                    else -> result.notImplemented()
                }
            }

        // EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    private fun handleAuthIntent(intent: Intent?) {
        if (intent == null) return
        val data = intent.data ?: return
        
        if (data.scheme == "rooster-auth" && data.host == "sber-id") {
            val code = data.getQueryParameter("code")
            val error = data.getQueryParameter("error")
            
            if (error != null) {
                val errorMessage = data.getQueryParameter("error_description") ?: error
                sendEventToFlutter("onSberAuthError", mapOf(
                    "error" to error,
                    "message" to errorMessage
                ))
            } else if (code != null) {
                sendEventToFlutter("onSberAuthSuccess", mapOf("code" to code))
            }
        }
    }

    private fun isSberAppInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo("ru.sbermobile.sbop", 0)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun sendEventToFlutter(method: String, arguments: Map<String, Any?>) {
        val event = mapOf("method" to method, "arguments" to arguments)
        eventSink?.success(event)
    }
}
```

### iOS (AppDelegate.swift)

```swift
import Flutter
import UIKit
import SberId

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let methodChannelName = "com.rooster.app/sber_auth"
    private let eventChannelName = "com.rooster.app/sber_auth/auth_events"
    private var eventSink: FlutterEventSink? = nil

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as? FlutterViewController
        
        if let controller = controller {
            // MethodChannel
            let methodChannel = FlutterMethodChannel(
                name: methodChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            methodChannel.setMethodCallHandler { [weak self] call, result in
                self?.handleMethodCall(call, result: result)
            }
            
            // EventChannel
            let eventChannel = FlutterEventChannel(
                name: eventChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            eventChannel.setStreamHandler(SberAuthStreamHandler { sink in
                self?.eventSink = sink
            })
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initSberSdk":
            let args = call.arguments as? [String: Any]
            let clientId = args?["clientId"] as? String ?? ""
            let scope = args?["scope"] as? String ?? "openid profile"
            
            if !clientId.isEmpty {
                SberId.configure(
                    clientId: clientId,
                    scope: scope,
                    state: "rooster_sber_state"
                )
            }
            result(true)

        case "startLogin":
            let controller = window?.rootViewController ?? UIViewController()
            SberId.login(from: controller) { authResult in
                switch authResult {
                case .success(let code):
                    self.sendEvent("onSberAuthSuccess", arguments: ["code": code])
                    result(true)
                case .failure(let error):
                    self.sendEvent("onSberAuthError", arguments: [
                        "error": error.code,
                        "message": error.localizedDescription
                    ])
                    result(FlutterError(
                        code: "SBER_SDK_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                case .cancelled:
                    self.sendEvent("onSberAuthError", arguments: [
                        "error": "SBER_ID_CANCELLED",
                        "message": "User cancelled"
                    ])
                    result(FlutterError(
                        code: "SBER_ID_CANCELLED",
                        message: "User cancelled",
                        details: nil
                    ))
                }
            }

        case "isAvailable":
            let available = UIApplication.shared.canOpenURL(
                URL(string: "sberbankonline://")!
            )
            result(available)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func sendEvent(_ method: String, arguments: [String: Any]) {
        let event: [String: Any] = ["method": method, "arguments": arguments]
        eventSink?(event)
    }

    override func application(_ app: UIApplication, open url: URL, options: [:] = [:]) -> Bool {
        return handleAuthUrl(url)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: [:]) -> Bool {
        if let url = userActivity.webpageURL {
            return handleAuthUrl(url)
        }
        return false
    }

    private func handleAuthUrl(_ url: URL) -> Bool {
        guard url.scheme == "rooster-auth" && url.host == "sber-id" else { return false }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems
        
        if let error = queryItems?.first(where: { $0.name == "error" })?.value {
            let message = queryItems?.first(where: { $0.name == "error_description" })?.value ?? error
            sendEvent("onSberAuthError", arguments: ["error": error, "message": message])
        } else if let code = queryItems?.first(where: { $0.name == "code" })?.value {
            sendEvent("onSberAuthSuccess", arguments: ["code": code])
        }
        return true
    }
}

class SberAuthStreamHandler: NSObject, FlutterStreamHandler {
    private let sinkRef: (FlutterEventSink?) -> Void
    init(eventSinkRef: @escaping (FlutterEventSink?) -> Void) {
        self.sinkRef = eventSinkRef
        super.init()
    }
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sinkRef(events)
        return nil
    }
    func onCancel(withArguments arguments: Any?) {
        sinkRef(nil)
    }
}
```

---

## Что меняется в Flutter

### SberAuthService — без изменений
Код уже использует MethodChannel + EventChannel, совместим с новым SDK.

### SberIdAuthGatewayImpl — без изменений
Stream-based API уже реализован корректно.

### build.gradle.kts — обновить зависимость

```gradle
dependencies {
    // Sber ID SDK — нативный SDK для App-to-App авторизации
    implementation('ru.sberid:sdk:2.0.0')
}
```

### Podfile — обновить pod

```ruby
pod 'SberId', '~> 2.0.0'
```

---

## Ключевые отличия от предыдущей реализации

| Аспект | Было (OAuth2 URL) | Стало (Native SDK) |
|--------|-------------------|-------------------|
| Авторизация | Формирование URL + браузер | `SberId.login()` |
| Callback | Intent/URL parsing | Callback из SDK |
| Fallback | Всегда браузер | SDK сам выбирает (app → browser) |
| Биометрия | Нет (веб-форма) | Да (Face ID / Touch ID) |
| UX | Переход в браузер | Нативное приложение Сбера |

---

## Порядок подключения

1. **Получить Client ID** в [developer.sber.ru](https://developer.sber.ru/) ✅ (уже есть в .env)
2. **Добавить зависимость** Android: `ru.sberid:sdk:2.0.0`
3. **Добавить pod** iOS: `SberId ~> 2.0.0`
4. **Выполнить** `cd android && ./gradlew clean && cd ../ios && pod install && cd ..`
5. **Раскомментировать** зависимости в build.gradle.kts и Podfile
6. **Протестировать** на устройстве с установленным СберБанк Онлайн

---

## Ссылки

- [Android SDK Documentation](https://developers.sber.ru/docs/ru/sberid/sdk/androidsdk/connection)
- [iOS SDK Documentation](https://developers.sber.ru/docs/ru/sberid/sdk/iossdk/connection)
- [Developer Portal](https://developer.sber.ru/)
