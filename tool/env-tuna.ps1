# Source this in your current terminal: . .\tool\env-tuna.ps1
$env:PUB_HOSTED_URL = "https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.tuna.tsinghua.edu.cn/flutter"
Write-Host "[OK] Tsinghua TUNA mirror active" -ForegroundColor Green
Write-Host "  PUB_HOSTED_URL=$env:PUB_HOSTED_URL"
Write-Host "  FLUTTER_STORAGE_BASE_URL=$env:FLUTTER_STORAGE_BASE_URL"
