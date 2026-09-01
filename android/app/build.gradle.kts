import java.io.File
import java.io.FileInputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.nio.charset.StandardCharsets
import java.util.Locale
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase: отключено (см. pubspec.yaml).
    // id("com.google.gms.google-services")
    // id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "ru.aronets.rooster"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "ru.aronets.rooster"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // CMake конфигурация для native LLM library
        externalNativeBuild {
            cmake {
                cppFlags += "-std=c++17"
                arguments += "-DANDROID_STL=c++_shared"
            }
        }

        val huaweiAppId =
            readHuaweiAppIdFromAgconnect(layout.projectDirectory.asFile).ifEmpty {
                readHuaweiAppIdFromAndroidLocalProperties(rootProject.layout.projectDirectory.asFile)
            }
        manifestPlaceholders["HUAWEI_APP_ID"] = huaweiAppId
        if (huaweiAppId.isEmpty()) {
            project.logger.lifecycle(
                "[Huawei] Нет client app_id: добавьте android/app/agconnect-services.json, " +
                    "либо положите тот же файл в android/app/src/main/assets/, " +
                    "либо huawei.app.id в android/local.properties — иначе в манифесте appid= и HMS пишет appid=null.",
            )
        }
    }

    externalNativeBuild {
        cmake {
            path = file("../../native/flutter_llm_bridge/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    // Копируем GGUF модель в assets (не сжимать)
    aaptOptions {
        noCompress("gguf")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile")!!)
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false

            signingConfig =
                if (hasReleaseKeystore) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.12.0")
        force("androidx.core:core-ktx:1.12.0")
        force("androidx.appcompat:appcompat:1.6.1")
        force("com.google.android.material:material:1.11.0")
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

/**
 * HMS / AG Connect SDK читает [agconnect-services.json] из assets APK.
 * Без плагина agcp файл только в корне [android/app] в пакет не попадает — копируем перед сборкой.
 */
tasks.register<Copy>("copyAgconnectServicesToAssets") {
    group = "huawei"
    description = "Копирует agconnect-services.json в src/main/assets для HMS (источник: android/app/agconnect-services.json)."
    val source = layout.projectDirectory.file("agconnect-services.json")
    onlyIf { source.asFile.exists() }
    from(source)
    into(layout.projectDirectory.dir("src/main/assets"))
}

// Совпадает с android:label в AndroidManifest — имя в артефактах APK/AAB.
private val appArtifactDisplayName = "Rooster"

/**
 * Читает [app_id] из первого найденного [agconnect-services.json]:
 * 1) [android/app/agconnect-services.json] (источник для копирования в assets),
 * 2) [android/app/src/main/assets/agconnect-services.json] (если конфиг только там — иначе manifestPlaceholders пустые и HMS: appid=null).
 */
private fun readHuaweiAppIdFromAgconnect(appModuleDir: File): String {
    val candidateFiles =
        listOf(
            File(appModuleDir, "agconnect-services.json"),
            File(appModuleDir, "src/main/assets/agconnect-services.json"),
        )
    for (candidate in candidateFiles) {
        if (!candidate.isFile) {
            continue
        }
        val appId = extractHuaweiAppIdFromAgConnectFile(candidate)
        if (appId.isNotEmpty()) {
            return appId
        }
    }
    return ""
}

private fun extractHuaweiAppIdFromAgConnectFile(file: File): String {
    return try {
        extractHuaweiAppIdFromAgConnectJson(file.readText(StandardCharsets.UTF_8))
    } catch (_: Exception) {
        ""
    }
}

/** Первое вхождение app_id (строка в кавычках или число без кавычек). */
private fun extractHuaweiAppIdFromAgConnectJson(jsonText: String): String {
    val quoted =
        Regex(""""app_id"\s*:\s*"([^"]+)"""")
            .find(jsonText)
            ?.groupValues
            ?.get(1)
            ?.trim()
            .orEmpty()
    if (quoted.isNotEmpty()) {
        return quoted
    }
    return Regex(""""app_id"\s*:\s*(\d+)""")
        .find(jsonText)
        ?.groupValues
        ?.get(1)
        ?.trim()
        .orEmpty()
}

/** Резерв: `huawei.app.id=...` в [android/local.properties] (файл обычно не в git). */
private fun readHuaweiAppIdFromAndroidLocalProperties(androidRootDir: File): String {
    val localProps = File(androidRootDir, "local.properties")
    if (!localProps.isFile) {
        return ""
    }
    return try {
        localProps
            .readLines()
            .map { line -> line.trim() }
            .firstOrNull { line -> line.startsWith("huawei.app.id=") }
            ?.substringAfter("=", "")
            ?.trim()
            .orEmpty()
    } catch (_: Exception) {
        ""
    }
}

/**
 * Дублирует собранный apk/aab как {имя}_{dd_MM_yyyy}_{debug|release}.{расширение}.
 * Оригинал (например `app-debug.apk`) не удаляется — его ищет Flutter tooling.
 */
private fun Project.copyBuiltArtifactWithDateSuffix(
    outputSubdirRelative: String,
    buildKind: String,
    extension: String,
) {
    val outputDir = layout.buildDirectory.dir(outputSubdirRelative).get().asFile
    if (!outputDir.isDirectory) return
    val datePrefix = SimpleDateFormat("dd_MM_yyyy", Locale.US).format(Date())
    val targetName = "${appArtifactDisplayName}_${datePrefix}_${buildKind}${extension}"
    val targetFile = File(outputDir, targetName)
    val sources =
        outputDir.listFiles { candidate ->
            candidate.isFile &&
                candidate.name.endsWith(extension, ignoreCase = true) &&
                !candidate.name.startsWith(appArtifactDisplayName)
        } ?: return
    if (sources.isEmpty()) return
    val sourceFile = sources.maxByOrNull { it.lastModified() } ?: return
    if (targetFile.exists()) {
        targetFile.delete()
    }
    sourceFile.copyTo(targetFile, overwrite = true)
}

afterEvaluate {
    tasks.named("preBuild").configure {
        dependsOn(tasks.named("copyAgconnectServicesToAssets"))
    }

    tasks.named("assembleDebug").configure {
        doLast {
            project.copyBuiltArtifactWithDateSuffix("outputs/apk/debug", "debug", ".apk")
            project.copyBuiltArtifactWithDateSuffix("outputs/flutter-apk", "debug", ".apk")
        }
    }

    tasks.named("assembleRelease").configure {
        doLast {
            project.copyBuiltArtifactWithDateSuffix("outputs/apk/release", "release", ".apk")
            project.copyBuiltArtifactWithDateSuffix("outputs/flutter-apk", "release", ".apk")
        }
    }

    tasks.named("bundleDebug").configure {
        doLast {
            project.copyBuiltArtifactWithDateSuffix("outputs/bundle/debug", "debug", ".aab")
        }
    }

    tasks.named("bundleRelease").configure {
        doLast {
            project.copyBuiltArtifactWithDateSuffix("outputs/bundle/release", "release", ".aab")
        }
    }
}
