# Настройка Firebase для всех платформ (после создания проекта в Firebase Console).
# Требуется: npm i -g firebase-tools, firebase login, dart pub global activate flutterfire_cli
#
# Использование:
#   .\tool\flutterfire_configure.ps1 -ProjectId your-project-id
param(
    [Parameter(Mandatory = $true)]
    [string] $ProjectId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-Location (Resolve-Path (Join-Path $PSScriptRoot ".."))

dart pub global run flutterfire_cli:flutterfire configure `
    -p $ProjectId `
    -y `
    --platforms=android,ios,macos,web,linux,windows `
    --android-package-name=ru.aronets.rooster `
    --ios-bundle-id=ru.aronets.rooster `
    --macos-bundle-id=ru.aronets.rooster `
    --out=lib/firebase_options.dart

Write-Host "Готово. Проверьте android/app/google-services.json, ios/Runner/GoogleService-Info.plist, macos/Runner/GoogleService-Info.plist и .firebaserc."
