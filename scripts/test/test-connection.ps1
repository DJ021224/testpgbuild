# ============================================================
# Module : test-connection.ps1
# Purpose: Smoke test -- verify psql connectivity and that
#          key Chinook tables are accessible
# Usage  : .\test-connection.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$DBHost,
    [Parameter(Mandatory=$true)][string]$DBUser,
    [Parameter(Mandatory=$true)][string]$DBPassword,
    [string]$DBPort  = '5432',
    [string]$DBName  = 'chinook',
    [string]$RootDir = 'D:\testpgbuild',
    [string]$LogDir  = 'D:\testpgbuild\logs'
)
$ErrorActionPreference = 'Stop'

. "$RootDir\scripts\utils\logger.ps1"
. "$RootDir\scripts\utils\common.ps1"

if (-not (Get-CurrentBuildId)) {
    Initialize-Logger -LogPath "$LogDir\conntest_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

Write-Log "CONNECTION SMOKE TEST" -Level SECTION
$pass = 0; $fail = 0

function Assert-True {
    param([string]$Label, [bool]$Condition)
    if ($Condition) { Write-Log "PASS: $Label" -Level SUCCESS; $script:pass++ }
    else            { Write-Log "FAIL: $Label" -Level ERROR;   $script:fail++ }
}

Assert-True "psql available"       (Test-PSQLAvailable)
Assert-True "PostgreSQL reachable" (Test-PostgreSQLConnection -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser -DBPassword $DBPassword)
Assert-True "Database '$DBName' exists" (Test-DatabaseExists -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser -DBPassword $DBPassword -DBName $DBName)

$tables = @('genre','mediatype','artist','album','track','employee','customer','invoice','invoiceline','playlist')
foreach ($tbl in $tables) {
    Assert-True "Table '$tbl' exists" (Test-TableExists -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser -DBPassword $DBPassword -DBName $DBName -TableName $tbl)
}

Write-LogSeparator
Write-Log "Connection tests: $pass passed, $fail failed." -Level INFO
if ($fail -gt 0) { Write-Log "SMOKE TEST FAILED." -Level ERROR; exit 1 }
Write-Log "SMOKE TEST PASSED." -Level SUCCESS
exit 0
