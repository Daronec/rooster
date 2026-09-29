@echo off
REM ============================================
REM Switch Flutter/Dart to Chinese mirrors
REM Usage: Run this script, then open a NEW
REM         terminal for changes to take effect.
REM ============================================

echo Setting Chinese mirrors for Flutter/Dart...

setx PUB_HOSTED_URL "https://pub.flutter-io.cn"
setx FLUTTER_STORAGE_BASE_URL "https://storage.flutter-io.cn"

echo.
echo [OK] Chinese mirrors configured:
echo   PUB_HOSTED_URL=https://pub.flutter-io.cn
echo   FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
echo.
echo IMPORTANT: Close and reopen your terminal/PowerShell
echo            for the changes to take effect.
echo.
pause
