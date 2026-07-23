# ============================================================
# Module : deploy-migrations.ps1
# Purpose: Apply all pending versioned migrations in order.
#          Skips already-applied versions tracked in
#          schema_migrations. Supports dry-run mode.
# Usage  : .\deploy-migrations.ps1 -DBHost localhost -DBUser admin -DBPassword admin@123
#           Add -DryRun to preview without applying
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$DBHost,
    [Parameter(Mandatory=$true)][string]$DBUser,
    [Parameter(Mandatory=$true)][string]$DBPassword,
    [string]$DBPort    = '5432',
    [string]$DBName    = 'chinook',
    [string]$RootDir   = 'D:\testpgbuild',
    [string]$LogDir    = 'D:\testpgbuild\logs',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

. "$RootDir\scripts\utils\logger.ps1"
. "$RootDir\scripts\utils\common.ps1"

if (-not (Get-CurrentBuildId)) {
    Initialize-Logger -LogPath "$LogDir\migrations_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

Write-Log "DATABASE MIGRATIONS$(if ($DryRun) {' [DRY-RUN]'})" -Level SECTION

$migDir = "$RootDir\database\migrations"
$migFiles = Get-ChildItem -Path $migDir -Filter "V*.sql" | Sort-Object Name

if ($migFiles.Count -eq 0) {
    Write-Log "No migration files found in $migDir." -Level WARN
    exit 0
}

# Fetch already-applied versions
$applied = Get-AppliedMigrations -DBHost $DBHost -DBPort $DBPort `
                                  -DBUser $DBUser -DBPassword $DBPassword -DBName $DBName

Write-Log "Applied versions: $(if ($applied) { $applied -join ', ' } else { 'none' })" -Level INFO
Write-Log "Available migration files: $($migFiles.Count)" -Level INFO
Write-LogSeparator

$applied_count = 0
$skipped_count = 0

foreach ($file in $migFiles) {
    # Extract version from filename: V002__create_chinook_schema.sql -> 002
    if ($file.Name -notmatch '^V(\d+)__(.+)\.sql$') {
        Write-Log "Skipping non-standard filename: $($file.Name)" -Level WARN
        continue
    }
    $version     = $Matches[1]
    $description = $Matches[2] -replace '_', ' '

    if ($applied -contains $version) {
        Write-Log "SKIP  V$version --already applied ($description)" -Level DEBUG
        $skipped_count++
        continue
    }

    Write-Log "APPLY V$version --$description" -Level INFO

    if (-not $DryRun) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        $r = Invoke-PSQLScript -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                                -DBPassword $DBPassword -DBName $DBName `
                                -ScriptPath $file.FullName
        $sw.Stop()
        $ms = $sw.ElapsedMilliseconds

        if ($r.ExitCode -ne 0) {
            Write-Log "FAILED V$version --$($r.Output)" -Level ERROR
            exit 1
        }

        # Compute checksum
        $checksum = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash

        # Record in schema_migrations
        $recSQL = "INSERT INTO schema_migrations (version, description, script_name, execution_ms, checksum) " +
                  "VALUES ('$version', '$description', '$($file.Name)', $ms, '$checksum') " +
                  "ON CONFLICT (version) DO NOTHING;"
        $recResult = Invoke-PSQLCommand -DBHost $DBHost -DBPort $DBPort -DBUser $DBUser `
                                         -DBPassword $DBPassword -DBName $DBName -Command $recSQL
        if ($recResult.ExitCode -ne 0) {
            Write-Log "WARNING: Could not record migration in schema_migrations." -Level WARN
        }

        Write-Log "DONE  V$version --applied in ${ms}ms" -Level SUCCESS
        $r.Output | Where-Object { $_ -match '\S' } | ForEach-Object { Write-Log "  $_" -Level DEBUG }
    } else {
        Write-Log "DRY   V$version --would apply $($file.Name)" -Level WARN
    }

    $applied_count++
}

Write-LogSeparator
Write-Log "Migrations: $applied_count applied, $skipped_count skipped." -Level SUCCESS
exit 0
