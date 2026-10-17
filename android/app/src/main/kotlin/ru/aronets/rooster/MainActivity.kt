package ru.aronets.rooster

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Регистрируем Flutter-плагины для инициализации VKID SDK
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
