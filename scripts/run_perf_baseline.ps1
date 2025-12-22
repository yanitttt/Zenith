<#
.SYNOPSIS
    Lance les tests de performance de base sur un device connecté.

.DESCRIPTION
    Ce script exécute 'flutter test integration_test' en mode profile avec les flags de performance activés.
    Il utilise 'fvm' comme demandé.

.EXAMPLE
    .\scripts\run_perf_baseline.ps1
#>

Write-Host "🚀 Lancement des tests de performance (Baseline)..." -ForegroundColor Cyan

# Vérification de FVM
if (!(Get-Command fvm -ErrorAction SilentlyContinue)) {
    Write-Error "FVM n'est pas installé ou n'est pas dans le PATH."
    exit 1
}

# Exécution: fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/perf_baseline_test.dart --profile --dart-define=PERF_MODE=true
Write-Host "Exécution: fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/perf_baseline_test.dart --profile --dart-define=PERF_MODE=true" -ForegroundColor Gray

# Nettoyage préalable pour éviter les erreurs de cache (Invalid SDK hash, Daemon failed...)
Write-Host "🧹 Nettoyage du projet..." -ForegroundColor Cyan
fvm flutter clean
fvm flutter pub get

# Exécution: fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/perf_baseline_test.dart --profile --dart-define=PERF_MODE=true
Write-Host "Exécution: fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/perf_baseline_test.dart --profile --dart-define=PERF_MODE=true" -ForegroundColor Gray

# Note: En PowerShell, passer des arguments avec = peut être délicat. On utilise la syntaxe directe sans quotes si possible, ou échappement.
fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/perf_baseline_test.dart --profile --dart-define=PERF_MODE=true

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Tests terminés avec succès." -ForegroundColor Green
} else {
    Write-Host "❌ Echec des tests." -ForegroundColor Red
}
