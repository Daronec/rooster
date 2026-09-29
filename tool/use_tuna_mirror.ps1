# ============================================
# Switch Flutter/Dart to Tsinghua TUNA mirror
# Usage: Run this script, then open a NEW
#        terminal for changes to take effect.
# ============================================

Write-Host "Setting Tsinghua TUNA mirror for Flutter/Dart..." -ForegroundColor Cyan

# Set for current session (immediate effect)
$env:PUB_HOSTED_URL = "https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.tuna.tsinghua.edu.cn/flutter"

# Set persistently for user (future sessions)
[System.Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://mirrors.tuna.tsinghua.edu.cn/dart-pub", "User")
[System.Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://mirrors.tuna.tsinghua.edu.cn/flutter", "User")

Write-Host ""
Write-Host "[OK] Tsinghua TUNA mirror configured:" -ForegroundColor Green
Write-Host "  PUB_HOSTED_URL=$env:PUB_HOSTED_URL"
Write-Host "  FLUTTER_STORAGE_BASE_URL=$env:FLUTTER_STORAGE_BASE_URL"
Write-Host ""
Write-Host "Now run: fvm flutter pub get" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
