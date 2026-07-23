# ============================================================
# Module : run-tests.ps1
# Purpose: Run all SQL test suites (unit + integration).
#          Exits non-zero if any test fails.
# Usage  : .\run-tests.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$DBHost,
    [Parameter(Mandatory=$true)][string]$DBUser,
    [Parameter(Mandatory=$true)][string]$DBPassword,
    [string]$DBPort    = '5432',
    [string]$DBName    = 'chinook',
    [string]$RootDir   = 'D:\testpgbuild',
    [string]$LogDir    = 'D:\testpgbuild\logs',
    [ValidateSet('all','unit','integration')]
    [string]$Suite     = 'all'
)
$ErrorActionPreference = 'Stop'

. "$RootDir\scripts\utils\logger.ps1"
. "$RootDir\scripts\utils\common.ps1"

if (-not (Get-CurrentBuildId)) {
    Initialize-Logger -LogPath "$LogDir\tests_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

Write-Log "RUN TEST SUITES [$Suite]" -Level SECTION

$testDirs = @()
if ($Suite -eq 'all' -or $Suite -eq 'unit')        { $testDirs += "$RootDir\tests\unit" }
if ($Suite -eq 'all' -or $Suite -eq 'integration') { $testDirs += "$RootDir\tests\integration" }

$totalPass = 0
$totalFail = 0

foreach ($dir in $testDirs) {
    $label = Split-Path $dir -Leaf
    Write-Log "--- Running $label tests ---" -Level INFO
    if (-not (Test-Path $dir)) { Write-Log "Test dir not found: $dir" -Level WARN; continue }

    $testFiles = Get-ChildItem -Path $dir -Filter "test_*.sql" | Sort-Object Name
    if ($testFiles.Count -eq 0) { Write-Log "No test files in $dir" -Level WARN; continue }

    foreach ($f in $testFiles) {
        Write-Log "Test: $($f.Name)" -Level INFO
        $r = Invoke-PSQLScript -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                                -DBPassword $DBPassword -DBName $DBName -ScriptPath $f.FullName
        if ($r.ExitCode -ne 0) {
            Write-Log "FAIL: $($f.Name)" -Level ERROR
            Write-Log $r.Output -Level DEBUG
            $totalFail++
        } else {
            # Check output for NOTICE lines containing FAIL
            $failLines = $r.Output -split "`n" | Where-Object { $_ -match 'FAIL' }
            if ($failLines) {
                Write-Log "FAIL (assertion): $($f.Name)" -Level ERROR
                $failLines | ForEach-Object { Write-Log "  $_" -Level ERROR }
                $totalFail++
            } else {
                Write-Log "PASS: $($f.Name)" -Level SUCCESS
                $totalPass++
            }
        }
    }
}

Write-LogSeparator
Write-Log "Test results: $totalPass passed, $totalFail failed." -Level INFO
if ($totalFail -gt 0) { Write-Log "TEST SUITE FAILED." -Level ERROR; exit 1 }
Write-Log "ALL TESTS PASSED." -Level SUCCESS
exit 0
