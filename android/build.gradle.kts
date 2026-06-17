allprojects {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://developer.huawei.com/repo/")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// AGP 8+: часть Flutter-плагинов Huawei не задаёт namespace (берём из package в их AndroidManifest).
subprojects {
    plugins.withId("com.android.library") {
        val namespace =
            when (name) {
                "innim_agconnect_crash" -> "com.huawei.agconnectcrash"
                "huawei_analytics" -> "com.huawei.hms.flutter.analytics"
                "huawei_account" -> "com.huawei.hms.flutter.account"
                else -> return@withId
            }
        val androidExt = extensions.getByName("android")
        androidExt.javaClass
            .getMethod("setNamespace", String::class.java)
            .invoke(androidExt, namespace)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
