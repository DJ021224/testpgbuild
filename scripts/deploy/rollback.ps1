# ============================================================
# Module : rollback.ps1
# Purpose: Roll back the last N applied migrations by running
#          the matching R*.sql scripts in database\rollback\.
#          Removes the version entry from schema_migrations.
# Usage  : .\rollback.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
#          .\rollback.ps1 ... -Steps 2     (roll back last 2)
#          .\rollback.ps1 ... -Version 003 (roll back specific version)
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$DBHost,
    [Parameter(Mandatory=$true)][string]$DBUser,
    [Parameter(Mandatory=$true)][string]$DBPassword,
    [string]$DBPort   = '5432',
    [string]$DBName   = 'chinook',
    [string]$RootDir  = 'D:\testpgbuild',
    [string]$LogDir   = 'D:\testpgbuild\logs',
    [int]$Steps       = 1,
    [string]$Version  = ''
)
$ErrorActionPreference = 'Stop'

. "$RootDir\scripts\utils\logger.ps1"
. "$RootDir\scripts\utils\common.ps1"

Initialize-Logger -LogPath "$LogDir\rollback_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

Write-Log "DATABASE ROLLBACK" -Level SECTION
Write-Log "WARNING: Rollback is a destructive operation. Data may be lost." -Level WARN

$applied = Get-AppliedMigrations -DBHost $DBHost -DBPort $DBPort `
                                  -DBUser $DBUser -DBPassword $DBPassword -DBName $DBName

if (-not $applied -or $applied.Count -eq 0) {
    Write-Log "No applied migrations found. Nothing to roll back." -Level WARN
    exit 0
}

# Determine target versions
$targets = if ($Version -ne '') {
    @($Version)
} else {
    ($applied | Sort-Object -Descending | Select-Object -First $Steps)
}

Write-Log "Versions to roll back: $($targets -join ', ')" -Level INFO

$rbDir = "$RootDir\database\rollback"

foreach ($ver in $targets) {
    $rbFile = Get-ChildItem -Path $rbDir -Filter "R$ver`__*.sql" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $rbFile) {
        Write-Log "No rollback script found for version $ver in $rbDir" -Level ERROR
        exit 1
    }

    Write-Log "Rolling back V$ver using $($rbFile.Name)..." -Level INFO
    $r = Invoke-PSQLScript -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                            -DBPassword $DBPassword -DBName $DBName -ScriptPath $rbFile.FullName
    if ($r.ExitCode -ne 0) {
        Write-Log "Rollback FAILED for V$ver — $($r.Output)" -Level ERROR
        exit 1
    }

    # Remove from tracking table
    $del = Invoke-PSQLCommand -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                               -DBPassword $DBPassword -DBName $DBName `
                               -Command "DELETE FROM schema_migrations WHERE version = '$ver';"
    if ($del.ExitCode -ne 0) {
        Write-Log "WARNING: Could not remove V$ver from schema_migrations." -Level WARN
    }

    Write-Log "V$ver rolled back successfully." -Level SUCCESS
}

Write-Log "Rollback completed." -Level SUCCESS
exit 0
