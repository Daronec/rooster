# ============================================
# Reset Flutter/Dart to official mirrors
# Usage: Run this script, then open a NEW
#        terminal for changes to take effect.
# ============================================

Write-Host "Resetting to official Flutter/Dart mirrors..." -ForegroundColor Cyan

[System.Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", $null, "User")
[System.Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", $null, "User")

Write-Host ""
Write-Host "[OK] Environment variables cleared." -ForegroundColor Green
Write-Host "      Flutter/Dart will now use official servers."
Write-Host ""
Write-Host "IMPORTANT: Close and reopen PowerShell/terminal" -ForegroundColor Yellow
Write-Host "            for the changes to take effect." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
