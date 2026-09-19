package ru.aronets.rooster

import android.content.Intent
import android.net.Uri
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
        // Обрабатываем входящий Intent при запуске приложения (OAuth callback)
        handleAuthIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Обрабатываем callback при возврате из браузера/приложения Сбера
        handleAuthIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineRef = flutterEngine

        // MethodChannel — для вызовов из Flutter (initSberSdk, startLogin, isAvailable)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initSberSdk" -> {
                        val clientId = call.argument<String>("clientId") ?: ""
                        val scope = call.argument<String>("scope") ?: "openid profile"

                        if (clientId.isNotEmpty()) {
                            // Инициализация нативного SDK Сбер ID
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
                        // Запуск нативного SDK login — открывает приложение Сбера или браузер
                        SberId.login(this, object : SberIdLoginCallback {
                            override fun onSuccess(code: String) {
                                // Успешная авторизация — получен authorization code
                                sendEventToFlutter("onSberAuthSuccess", mapOf("code" to code))
                                result.success(true)
                            }

                            override fun onError(error: SberIdError) {
                                // Ошибка авторизации от SDK
                                sendEventToFlutter("onSberAuthError", mapOf(
                                    "error" to error.code.toString(),
                                    "message" to error.message
                                ))
                                result.error("SBER_SDK_ERROR", error.message, null)
                            }

                            override fun onCancel() {
                                // Пользователь отменил вход
                                sendEventToFlutter("onSberAuthError", mapOf(
                                    "error" to "SBER_ID_CANCELLED",
                                    "message" to "User cancelled"
                                ))
                                result.error("SBER_ID_CANCELLED", "User cancelled", null)
                            }
                        })
                    }
                    "isAvailable" -> {
                        // Проверяем, установлено ли приложение СберБанк Онлайн
                        val available = isSberAppInstalled()
                        result.success(available)
                    }
                    else -> result.notImplemented()
                }
            }

        // EventChannel — для отправки событий во Flutter (onSberAuthSuccess, onSberAuthError)
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

    /**
     * Обрабатывает входящий Intent с OAuth callback.
     * Вызывается при запуске приложения или возврате из браузера/приложения Сбера.
     */
    private fun handleAuthIntent(intent: Intent?) {
        if (intent == null) return

        val data: Uri? = intent.data ?: return
        val scheme = data.scheme
        val host = data.host

        // Проверяем, что это callback от Сбера
        if (scheme == "rooster-auth" && host == "sber-id") {
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

    /**
     * Проверяет, установлено ли приложение СберБанк Онлайн.
     */
    private fun isSberAppInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo("ru.sbermobile.sbop", 0)
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Отправляет событие во Flutter через EventChannel.
     */
    private fun sendEventToFlutter(method: String, arguments: Map<String, Any?>) {
        val event = mapOf(
            "method" to method,
            "arguments" to arguments
        )
        eventSink?.success(event)
    }
}
