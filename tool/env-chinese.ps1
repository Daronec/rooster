# Source this in your current terminal: . .\tool\env-chinese.ps1
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
Write-Host "[OK] Chinese mirror active" -ForegroundColor Green
Write-Host "  PUB_HOSTED_URL=$env:PUB_HOSTED_URL"
Write-Host "  FLUTTER_STORAGE_BASE_URL=$env:FLUTTER_STORAGE_BASE_URL"
