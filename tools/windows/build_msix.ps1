# Сборка release и упаковка в MSIX (установщик Windows).
# Требуется: Flutter SDK, Visual Studio с C++ для Windows, при тестовой подписи — режим разработчика.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

flutter pub get
dart run msix:create
