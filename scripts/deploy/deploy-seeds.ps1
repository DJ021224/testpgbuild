# ============================================================
# Module : deploy-seeds.ps1
# Purpose: Load sample / seed data into the database.
#          Checks row counts to avoid double-seeding.
#          Seed files are applied in numeric order (01_, 02_...)
# Usage  : .\deploy-seeds.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
#           Add -Force to reseed even if data already exists
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$DBHost,
    [Parameter(Mandatory=$true)][string]$DBUser,
    [Parameter(Mandatory=$true)][string]$DBPassword,
    [string]$DBPort  = '5432',
    [string]$DBName  = 'chinook',
    [string]$RootDir = 'D:\testpgbuild',
    [string]$LogDir  = 'D:\testpgbuild\logs',
    [switch]$Force
)
$ErrorActionPreference = 'Stop'

. "$RootDir\scripts\utils\logger.ps1"
. "$RootDir\scripts\utils\common.ps1"

if (-not (Get-CurrentBuildId)) {
    Initialize-Logger -LogPath "$LogDir\seeds_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

Write-Log "SEED DATA" -Level SECTION

# Guard: skip seeding if data already present and -Force not set
$artistCount = Get-RowCount -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                             -DBPassword $DBPassword -DBName $DBName -TableName 'artist'
if ($artistCount -gt 0 -and -not $Force) {
    Write-Log "Artist table already has $artistCount row(s). Skipping seed (use -Force to override)." -Level WARN
    exit 0
}

$seedDir   = "$RootDir\database\seeds"
$seedFiles = Get-ChildItem -Path $seedDir -Filter "*.sql" | Sort-Object Name

if ($seedFiles.Count -eq 0) {
    Write-Log "No seed files found in $seedDir." -Level WARN
    exit 0
}

foreach ($file in $seedFiles) {
    Write-Log "Applying seed: $($file.Name)" -Level INFO
    $r = Invoke-PSQLScript -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                            -DBPassword $DBPassword -DBName $DBName -ScriptPath $file.FullName
    if ($r.ExitCode -ne 0) {
        Write-Log "Seed FAILED: $($file.Name) -- $($r.Output)" -Level ERROR
        exit 1
    }
    Write-Log "Seed OK: $($file.Name)" -Level SUCCESS
}

# Summary row counts
Write-Log "Row counts after seeding:" -Level INFO
@('genre','mediatype','artist','album','track','employee','customer','invoice','invoiceline','playlist') | ForEach-Object {
    $cnt = Get-RowCount -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                        -DBPassword $DBPassword -DBName $DBName -TableName $_
    Write-Log "  $_ : $cnt row(s)" -Level INFO
}
Write-Log "Seeding completed." -Level SUCCESS
exit 0
