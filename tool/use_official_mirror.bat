@echo off
REM ============================================
REM Reset Flutter/Dart to official mirrors
REM Usage: Run this script, then open a NEW
REM         terminal for changes to take effect.
REM ============================================

echo Resetting to official Flutter/Dart mirrors...

setx PUB_HOSTED_URL ""
setx FLUTTER_STORAGE_BASE_URL ""

echo.
echo [OK] Environment variables cleared.
echo       Flutter/Dart will now use official servers.
echo.
echo IMPORTANT: Close and reopen your terminal/PowerShell
echo            for the changes to take effect.
echo.
pause
