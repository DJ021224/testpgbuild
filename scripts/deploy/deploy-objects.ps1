# ============================================================
# Module : deploy-objects.ps1
# Purpose: Deploy all database objects -- procedures, functions,
#          and views -- in the correct dependency order.
#          Objects are idempotent (CREATE OR REPLACE).
# Usage  : .\deploy-objects.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
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
    Initialize-Logger -LogPath "$LogDir\objects_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

Write-Log "DEPLOY DATABASE OBJECTS" -Level SECTION

# Deployment order matters: functions -> procedures -> views
$objectDirs = @(
    @{ Path = "$RootDir\database\functions";  Label = "Functions"  },
    @{ Path = "$RootDir\database\procedures"; Label = "Procedures" },
    @{ Path = "$RootDir\database\views";      Label = "Views"      }
)

$totalApplied = 0
$totalFailed  = 0

foreach ($dir in $objectDirs) {
    Write-Log "--- $($dir.Label) ---" -Level INFO
    if (-not (Test-Path $dir.Path)) {
        Write-Log "Directory not found, skipping: $($dir.Path)" -Level WARN
        continue
    }
    $sqlFiles = Get-ChildItem -Path $dir.Path -Filter "*.sql" | Sort-Object Name
    if ($sqlFiles.Count -eq 0) {
        Write-Log "No SQL files in $($dir.Path)." -Level DEBUG
        continue
    }
    foreach ($file in $sqlFiles) {
        Write-Log "Applying: $($file.Name)" -Level INFO
        $r = Invoke-PSQLScript -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                                -DBPassword $DBPassword -DBName $DBName -ScriptPath $file.FullName
        if ($r.ExitCode -ne 0) {
            Write-Log "FAILED: $($file.Name) -- $($r.Output)" -Level ERROR
            $totalFailed++
        } else {
            Write-Log "OK: $($file.Name)" -Level SUCCESS
            $totalApplied++
        }
    }
}

Write-LogSeparator
if ($totalFailed -gt 0) {
    Write-Log "Object deployment completed with $totalFailed failure(s)." -Level ERROR
    exit 1
}
Write-Log "All database objects deployed: $totalApplied object(s)." -Level SUCCESS
exit 0
