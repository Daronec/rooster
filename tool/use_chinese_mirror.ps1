# ============================================
# Switch Flutter/Dart to Chinese mirrors
# Usage: Run this script, then open a NEW
#        terminal for changes to take effect.
# ============================================

Write-Host "Setting Chinese mirrors for Flutter/Dart..." -ForegroundColor Cyan

# Set for current session (immediate effect)
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# Set persistently for user (future sessions)
[System.Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[System.Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")

Write-Host ""
Write-Host "[OK] Chinese mirrors configured:" -ForegroundColor Green
Write-Host "  PUB_HOSTED_URL=$env:PUB_HOSTED_URL"
Write-Host "  FLUTTER_STORAGE_BASE_URL=$env:FLUTTER_STORAGE_BASE_URL"
Write-Host ""
Write-Host "Now run: fvm flutter pub get" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
