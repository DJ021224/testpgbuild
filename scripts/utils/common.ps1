# ============================================================
# Module : common.ps1
# Purpose: Shared database utility functions used by all
#          build/deploy/test scripts
# ============================================================

function Test-PSQLAvailable {
    $cmd = Get-Command psql -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }
    return $true
}

function Test-PostgreSQLConnection {
    param(
        [string]$DBHost,
        [string]$DBPort     = '5432',
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName     = 'postgres'
    )
    $env:PGPASSWORD = $DBPassword
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $null = & psql -h $DBHost -p $DBPort -U $DBUser -d $DBName `
                   -c "SELECT 1;" 2>&1
    $ok = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    return $ok
}

function Invoke-PSQLScript {
    param(
        [string]$DBHost,
        [string]$DBPort     = '5432',
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName,
        [string]$ScriptPath
    )
    if (-not (Test-Path $ScriptPath)) {
        return @{ ExitCode = 1; Output = "Script not found: $ScriptPath" }
    }
    $env:PGPASSWORD = $DBPassword
    # Temporarily lower error preference: psql writes NOTICE/WARNING to stderr
    # which PowerShell 5.x with Stop preference turns into a terminating
    # NativeCommandError even though $LASTEXITCODE is 0.
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output   = & psql -h $DBHost -p $DBPort -U $DBUser -d $DBName `
                       -v ON_ERROR_STOP=1 -f $ScriptPath 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    return @{ ExitCode = $exitCode; Output = ($output -join "`n") }
}

function Invoke-PSQLCommand {
    param(
        [string]$DBHost,
        [string]$DBPort     = '5432',
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName,
        [string]$Command
    )
    $env:PGPASSWORD = $DBPassword
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output   = & psql -h $DBHost -p $DBPort -U $DBUser -d $DBName `
                       -v ON_ERROR_STOP=1 -c $Command 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    return @{ ExitCode = $exitCode; Output = ($output -join "`n") }
}

function Get-AppliedMigrations {
    param(
        [string]$DBHost,
        [string]$DBPort,
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName
    )
    $env:PGPASSWORD = $DBPassword
    $saved = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $output = & psql -h $DBHost -p $DBPort -U $DBUser -d $DBName -t -A `
                     -c "SELECT version FROM schema_migrations ORDER BY version;" 2>&1
    $ok = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    if ($ok) { return $output | Where-Object { $_ -match '\S' } | ForEach-Object { $_.Trim() } }
    return @()
}

function Test-DatabaseExists {
    param(
        [string]$DBHost,
        [string]$DBPort,
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName
    )
    $env:PGPASSWORD = $DBPassword
    $saved = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $output = & psql -h $DBHost -p $DBPort -U $DBUser -d postgres -t -A `
                     -c "SELECT 1 FROM pg_database WHERE datname='$DBName';" 2>&1
    $ok = ($LASTEXITCODE -eq 0 -and ($output -join "") -match "1")
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    return $ok
}

function Test-TableExists {
    param(
        [string]$DBHost,
        [string]$DBPort,
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName,
        [string]$TableName,
        [string]$Schema = 'public'
    )
    $sql = "SELECT 1 FROM information_schema.tables WHERE table_schema='$Schema' AND table_name='$TableName';"
    $env:PGPASSWORD = $DBPassword
    $saved = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $output = & psql -h $DBHost -p $DBPort -U $DBUser -d $DBName -t -A -c $sql 2>&1
    $ok = ($LASTEXITCODE -eq 0 -and ($output -join "") -match "1")
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    return $ok
}

function Get-RowCount {
    param(
        [string]$DBHost,
        [string]$DBPort,
        [string]$DBUser,
        [string]$DBPassword,
        [string]$DBName,
        [string]$TableName
    )
    $env:PGPASSWORD = $DBPassword
    $saved = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $output = & psql -h $DBHost -p $DBPort -U $DBUser -d $DBName -t -A `
                     -c "SELECT COUNT(*) FROM $TableName;" 2>&1
    $ok = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $saved
    $env:PGPASSWORD = $null
    if ($ok) { return [int]($output -join "").Trim() }
    return -1
}

function Load-EnvFile {
    param([string]$EnvPath)
    if (-not (Test-Path $EnvPath)) { return }
    Get-Content $EnvPath | Where-Object { $_ -match '^\s*[^#].*=.*' } | ForEach-Object {
        $parts = $_ -split '=', 2
        $key   = $parts[0].Trim()
        $val   = $parts[1].Trim().Trim('"').Trim("'")
        [System.Environment]::SetEnvironmentVariable($key, $val, 'Process')
    }
}
