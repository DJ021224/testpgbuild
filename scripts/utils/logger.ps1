# ============================================================
# Module : logger.ps1
# Purpose: Structured logging — console + file output
# ============================================================

$script:LogFile = $null
$script:BuildId = $null

function Initialize-Logger {
    param(
        [Parameter(Mandatory=$true)][string]$LogPath,
        [string]$BuildId = (Get-Date -Format 'yyyyMMdd_HHmmss')
    )
    $script:LogFile  = $LogPath
    $script:BuildId  = $BuildId
    $dir = Split-Path $LogPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $header = @"
================================================================
  TESTPGBUILD — Build Log
  Build ID : $BuildId
  Started  : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
  Machine  : $env:COMPUTERNAME
================================================================
"@
    $header | Out-File -FilePath $script:LogFile -Encoding utf8
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS','DEBUG','SECTION')]
        [string]$Level = 'INFO'
    )
    $ts    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$ts] [$Level] $Message"

    switch ($Level) {
        'INFO'    { Write-Host $entry -ForegroundColor Cyan    }
        'WARN'    { Write-Host $entry -ForegroundColor Yellow  }
        'ERROR'   { Write-Host $entry -ForegroundColor Red     }
        'SUCCESS' { Write-Host $entry -ForegroundColor Green   }
        'DEBUG'   { Write-Host $entry -ForegroundColor Gray    }
        'SECTION' {
            $line = "=" * 60
            Write-Host "`n$line"        -ForegroundColor Magenta
            Write-Host "  $Message"     -ForegroundColor Magenta
            Write-Host "$line`n"        -ForegroundColor Magenta
            $entry = "[$ts] [SECTION] $('=' * 20) $Message $('=' * 20)"
        }
    }

    if ($script:LogFile) {
        $entry | Out-File -FilePath $script:LogFile -Append -Encoding utf8
    }
}

function Write-LogSeparator {
    Write-Log ("-" * 60) -Level DEBUG
}

function Get-CurrentLogFile { return $script:LogFile }
function Get-CurrentBuildId { return $script:BuildId }
