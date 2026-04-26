# ═══════════════════════════════════════════════════════
#  Xixero Installer for Windows
#  https://jinkaka98.github.io
#
#  No Go, Python, or Node.js required.
#  Downloads pre-built binary from jinkaka98.github.io
# ═══════════════════════════════════════════════════════

$baseUrl = "https://jinkaka98.github.io/releases"
$installDir = "$env:LOCALAPPDATA\xixero"
$exePath = "$installDir\xixero.exe"

function Write-Step($num, $total, $msg) {
    Write-Host "[$num/$total] " -NoNewline -ForegroundColor DarkYellow
    Write-Host $msg -ForegroundColor Yellow
}
function Write-OK($msg)   { Write-Host "       $msg" -ForegroundColor Green }
function Write-Info($msg)  { Write-Host "       $msg" -ForegroundColor DarkGray }
function Write-Err($msg)  { Write-Host "  ERROR: $msg" -ForegroundColor Red }

# ─── Header ───
Write-Host ""
Write-Host "  ╔═══════════════════════════════════╗" -ForegroundColor DarkYellow
Write-Host "  ║                                   ║" -ForegroundColor DarkYellow
Write-Host "  ║      XIXERO INSTALLER             ║" -ForegroundColor DarkYellow
Write-Host "  ║      Local AI Gateway             ║" -ForegroundColor DarkYellow
Write-Host "  ║                                   ║" -ForegroundColor DarkYellow
Write-Host "  ╚═══════════════════════════════════╝" -ForegroundColor DarkYellow
Write-Host ""

# ─── Step 1: System Check ───
Write-Step 1 5 "Checking system requirements..."

if ($env:OS -ne "Windows_NT") {
    Write-Err "Windows only. For Linux/macOS download from jinkaka98.github.io"
    exit 1
}
Write-Info "Windows OK"

$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -lt 5) {
    Write-Err "PowerShell 5+ required (you have $($psVer.Major))"
    exit 1
}
Write-Info "PowerShell $($psVer.Major).$($psVer.Minor)"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Info "TLS 1.2"

try {
    $null = Invoke-WebRequest -Uri "https://jinkaka98.github.io" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Info "Internet OK"
} catch {
    Write-Err "Cannot reach jinkaka98.github.io - check internet"
    exit 1
}

Write-OK "All checks passed"

# ─── Step 2: Check Version ───
Write-Step 2 5 "Checking latest version..."

$version = $null
$downloadUrl = $null

try {
    $latest = Invoke-RestMethod "$baseUrl/latest.json" -TimeoutSec 15 -ErrorAction Stop
    $version = $latest.version
    $downloadUrl = $latest.binaries.'windows-amd64'.url
    $fileSize = $latest.binaries.'windows-amd64'.size

    Write-OK "Latest: v$version"
    if ($fileSize) {
        Write-Info "Size: $([math]::Round($fileSize / 1MB, 1))MB"
    }
} catch {
    Write-Info "No release metadata found"
    # Fallback: try direct binary URL
    $downloadUrl = "$baseUrl/xixero-windows-amd64.exe"
    Write-Info "Trying direct download..."
}

# Check existing
if (Test-Path $exePath) {
    try {
        $currentVer = (& $exePath version 2>&1) -join " "
        Write-Info "Installed: $currentVer"
    } catch {}
}

# ─── Step 3: Download ───
Write-Step 3 5 "Downloading Xixero..."

New-Item -ItemType Directory -Path $installDir -Force | Out-Null

if ($downloadUrl) {
    # Backup existing
    if (Test-Path $exePath) {
        Copy-Item $exePath "$exePath.bak" -Force -ErrorAction SilentlyContinue
        Write-Info "Backed up existing binary"
    }

    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
        $ProgressPreference = 'Continue'

        $dlSize = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
        Write-OK "Downloaded (${dlSize}MB)"
    } catch {
        $errMsg = $_.Exception.Message
        if ($errMsg -like "*404*") {
            Write-Err "Binary not published yet"
            Write-Host ""
            Write-Host "  No release available. Ask admin for the binary." -ForegroundColor DarkYellow
            Write-Host "  Place xixero.exe in: $installDir" -ForegroundColor DarkGray
            Write-Host ""
        } else {
            Write-Err "Download failed: $errMsg"
            # Restore backup
            if (Test-Path "$exePath.bak") {
                Move-Item "$exePath.bak" $exePath -Force
                Write-Info "Restored previous version"
            }
        }
    }
} else {
    Write-Err "No download URL available"
}

# ─── Step 4: PATH ───
Write-Step 4 5 "Configuring PATH..."

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    $env:Path = "$env:Path;$installDir"
    Write-OK "Added to PATH"
} else {
    Write-Info "Already in PATH"
}

# ─── Step 5: Verify ───
Write-Step 5 5 "Verifying..."

if (Test-Path $exePath) {
    try {
        $verOut = (& $exePath version 2>&1) -join " "
        Write-Info $verOut
    } catch {
        Write-Info "Binary OK (version check skipped)"
    }

    # Cleanup backup
    Remove-Item "$exePath.bak" -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║      INSTALLATION COMPLETE!               ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Location : $installDir" -ForegroundColor White
    if ($version) { Write-Host "  Version  : v$version" -ForegroundColor White }
    Write-Host ""
    Write-Host "  ┌─ Quick Start ─────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  1. Open a NEW terminal                    │" -ForegroundColor White
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  2. Activate license:                      │" -ForegroundColor White
    Write-Host "  │     xixero activate YOUR-LICENSE-KEY       │" -ForegroundColor Yellow
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  3. Start gateway:                         │" -ForegroundColor White
    Write-Host "  │     xixero start                           │" -ForegroundColor Yellow
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  4. IDE endpoint:                          │" -ForegroundColor White
    Write-Host "  │     http://localhost:7860/v1                │" -ForegroundColor Yellow
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  └────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  Binary not yet available." -ForegroundColor DarkYellow
    Write-Host "  PATH is configured. Run installer again when release is ready." -ForegroundColor DarkGray
    Write-Host "    irm https://jinkaka98.github.io/install.ps1 | iex" -ForegroundColor Cyan
    Write-Host ""
}
