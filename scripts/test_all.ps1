# BookMyPT — Cihaza Yüklemeden Önce Test Scripti
# Kullanım: cd C:\Dev\BookMyPt && .\scripts\test_all.ps1

$flutter = "C:\flutter\bin\flutter.bat"
$errors  = 0

function Step([string]$title) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Ok([string]$msg)   { Write-Host "  ✅  $msg" -ForegroundColor Green }
function Fail([string]$msg) { Write-Host "  ❌  $msg" -ForegroundColor Red; $script:errors++ }
function Info([string]$msg) { Write-Host "  ℹ️   $msg" -ForegroundColor Yellow }

# ─── 1. Dart/Flutter Analiz ───────────────────────────────────────────────────
Step "1 / 3  |  flutter analyze (tip & derleme hataları)"

$analyzeOut = & $flutter analyze 2>&1
$analyzeText = $analyzeOut -join "`n"

# Error sayısını bul
$errorLines = $analyzeOut | Where-Object { $_ -match "^\s+error " }
$warnLines  = $analyzeOut | Where-Object { $_ -match "^\s+warning " }
$infoLines  = $analyzeOut | Where-Object { $_ -match "^\s+info " }

if ($errorLines.Count -gt 0) {
    Fail "Derleme hatası bulundu: $($errorLines.Count) error"
    $errorLines | ForEach-Object { Write-Host "       $_" -ForegroundColor Red }
} else {
    Ok "Derleme hatası yok"
}

if ($warnLines.Count -gt 0) {
    Info "$($warnLines.Count) warning (derlemeyi engellemez)"
} else {
    Ok "Warning yok"
}

Info "$($infoLines.Count) info notu var"

# ─── 2. Unit Testler ──────────────────────────────────────────────────────────
Step "2 / 3  |  flutter test (unit testler)"

$testOut  = & $flutter test --reporter=expanded 2>&1
$testText = $testOut -join "`n"

$passed = ($testOut | Select-String "^\s+\+\d+.*:.*All tests passed" | Measure-Object).Count
$failed = ($testOut | Where-Object { $_ -match "FAILED|Some tests failed" }).Count

# Test sayımı
$totalTests  = ($testOut | Where-Object { $_ -match "^\s+\+" }).Count
$failedTests = ($testOut | Where-Object { $_ -match "^\s+-" }).Count

if ($failedTests -gt 0 -or ($testText -match "Some tests failed")) {
    Fail "Bazı testler başarısız: $failedTests test"
    $testOut | Where-Object { $_ -match "FAILED|Expected:|Actual:|Error:" } |
        ForEach-Object { Write-Host "       $_" -ForegroundColor Red }
} elseif ($testText -match "No tests ran") {
    Info "Hiç test bulunamadı — test dosyaları eksik olabilir"
} else {
    Ok "Tüm testler geçti"
}

# Test detaylarını göster
$testOut | Where-Object { $_ -match "^\s+\+" -or $_ -match "test\s" } |
    Select-Object -Last 5 |
    ForEach-Object { Write-Host "       $_" -ForegroundColor Gray }

# ─── 3. Paket / Bağımlılık Kontrolü ─────────────────────────────────────────
Step "3 / 3  |  flutter pub outdated (kritik güncellemeler)"

$pubOut  = & $flutter pub outdated 2>&1
$pubText = $pubOut -join "`n"

if ($pubText -match "No dependencies") {
    Ok "Tüm paketler güncel"
} else {
    $majorUpdates = ($pubOut | Where-Object { $_ -match "\*" }).Count
    if ($majorUpdates -gt 0) {
        Info "$majorUpdates paketin güncellemesi var (build'i engellemez)"
    } else {
        Ok "Kritik güncelleme yok"
    }
}

# ─── Özet ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
if ($errors -eq 0) {
    Write-Host "  ✅  Tüm kontroller geçti — cihaza yüklemeye hazır!" -ForegroundColor Green
} else {
    Write-Host "  ❌  $errors sorun bulundu — önce düzeltin!" -ForegroundColor Red
}
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host ""

exit $errors
