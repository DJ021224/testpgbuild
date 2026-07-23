# ============================================================
# Module : setup-database.ps1
# Purpose: Create the target database if it doesn't exist,
#          and bootstrap the schema_migrations tracking table
# Usage  : .\setup-database.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
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
    Initialize-Logger -LogPath "$LogDir\setup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

Write-Log "DATABASE SETUP" -Level SECTION

# --- 1. Create database if missing ----------------------------------------
Write-Log "Checking if database '$DBName' exists..." -Level INFO
$exists = Test-DatabaseExists -DBHost $DBHost -DBPort $DBPort `
                               -DBUser $DBUser -DBPassword $DBPassword -DBName $DBName
if ($exists) {
    Write-Log "Database '$DBName' already exists." -Level INFO
} else {
    Write-Log "Creating database '$DBName'..." -Level INFO
    $r = Invoke-PSQLCommand -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                             -DBPassword $DBPassword -DBName 'postgres' `
                             -Command "CREATE DATABASE $DBName OWNER $DBUser ENCODING 'UTF8';"
    if ($r.ExitCode -ne 0) {
        Write-Log "Failed to create database: $($r.Output)" -Level ERROR
        exit 1
    }
    Write-Log "Database '$DBName' created successfully." -Level SUCCESS
}

# --- 2. Create schema_migrations table ------------------------------------
Write-Log "Bootstrapping schema_migrations tracking table..." -Level INFO
$bootstrapSQL = @"
CREATE TABLE IF NOT EXISTS schema_migrations (
    version        VARCHAR(30)  NOT NULL PRIMARY KEY,
    description    VARCHAR(200) NOT NULL,
    script_name    VARCHAR(300) NOT NULL,
    applied_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    applied_by     VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    execution_ms   INTEGER,
    checksum       VARCHAR(64)
);

COMMENT ON TABLE schema_migrations IS 'Tracks applied database migration versions';
"@
$tmp = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.sql'
$bootstrapSQL | Out-File -FilePath $tmp -Encoding utf8
$r = Invoke-PSQLScript -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                        -DBPassword $DBPassword -DBName $DBName -ScriptPath $tmp
Remove-Item $tmp -Force
if ($r.ExitCode -ne 0) {
    Write-Log "Failed to bootstrap schema_migrations: $($r.Output)" -Level ERROR
    exit 1
}
Write-Log "schema_migrations table is ready." -Level SUCCESS

Write-Log "Database setup completed." -Level SUCCESS
exit 0
