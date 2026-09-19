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
            // MethodChannel — для вызовов из Flutter (initSberSdk, startLogin, isAvailable)
            let methodChannel = FlutterMethodChannel(
                name: methodChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            methodChannel.setMethodCallHandler { [weak self] call, result in
                self?.handleMethodCall(call, result: result)
            }
            
            // EventChannel — для отправки событий во Flutter
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

    /**
     * Обрабатывает вызовы методов из Flutter.
     */
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initSberSdk":
            let args = call.arguments as? [String: Any]
            let clientId = args?["clientId"] as? String ?? ""
            let scope = args?["scope"] as? String ?? "openid profile"
            
            if !clientId.isEmpty {
                // Инициализация нативного SDK Сбер ID
                SberId.configure(
                    clientId: clientId,
                    scope: scope,
                    state: "rooster_sber_state"
                )
            }
            result(true)

        case "startLogin":
            // Запуск нативного SDK login
            let controller = window?.rootViewController ?? UIViewController()
            SberId.login(from: controller) { authResult in
                switch authResult {
                case .success(let code):
                    // Успешная авторизация — получен authorization code
                    self.sendEvent("onSberAuthSuccess", arguments: ["code": code])
                    result(true)
                    
                case .failure(let error):
                    // Ошибка авторизации от SDK
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
                    // Пользователь отменил вход
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
            // Проверяем, установлено ли приложение СберБанк Онлайн
            let available = UIApplication.shared.canOpenURL(
                URL(string: "sberbankonline://")!
            )
            result(available)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /**
     * Отправляет событие во Flutter через EventChannel.
     */
    private func sendEvent(_ method: String, arguments: [String: Any]) {
        let event: [String: Any] = [
            "method": method,
            "arguments": arguments
        ]
        eventSink?(event)
    }

    /**
     * Обрабатывает открытие URL извне (OAuth callback).
     * Вызывается, когда пользователь возвращается в приложение после авторизации.
     */
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return handleAuthUrl(url)
    }

    /**
     * Обрабатывает URL для iOS 13+ (SceneDelegate / Universal Links).
     */
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL {
            return handleAuthUrl(url)
        }
        return false
    }

    /**
     * Обрабатывает OAuth callback URL.
     * Извлекает code из URL и отправляет во Flutter через EventChannel.
     */
    private func handleAuthUrl(_ url: URL) -> Bool {
        let scheme = url.scheme
        let host = url.host

        // Проверяем, что это callback от Сбера
        if scheme == "rooster-auth" && host == "sber-id" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let queryItems = components?.queryItems

            if let error = queryItems?.first(where: { $0.name == "error" })?.value {
                let errorMessage = queryItems?.first(where: { $0.name == "error_description" })?.value ?? error
                sendEvent("onSberAuthError", arguments: [
                    "error": error,
                    "message": errorMessage
                ])
            } else if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                sendEvent("onSberAuthSuccess", arguments: ["code": code])
            }
            return true
        }

        return false
    }
}

/**
 * StreamHandler для EventChannel — обрабатывает подключение/отключение слушателя во Flutter.
 */
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
