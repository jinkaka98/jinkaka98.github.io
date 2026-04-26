# ═══════════════════════════════════════════════════════
#  Xixero Installer for Windows
#  https://jinkaka98.github.io
#
#  User does NOT need Go, Python, Node, or any dev tools.
#  This installer downloads a pre-built binary.
# ═══════════════════════════════════════════════════════

$repo = "jinkaka98/xixero"
$installDir = "$env:LOCALAPPDATA\xixero"
$exePath = "$installDir\xixero.exe"

function Write-Step($num, $total, $msg) {
    Write-Host "[$num/$total] " -NoNewline -ForegroundColor DarkYellow
    Write-Host $msg -ForegroundColor Yellow
}

function Write-OK($msg) {
    Write-Host "       $msg" -ForegroundColor Green
}

function Write-Info($msg) {
    Write-Host "       $msg" -ForegroundColor DarkGray
}

function Write-Err($msg) {
    Write-Host "  ERROR: " -NoNewline -ForegroundColor Red
    Write-Host $msg -ForegroundColor White
}

# ─── Header ───
Write-Host ""
Write-Host "  ╔═══════════════════════════════════╗" -ForegroundColor DarkYellow
Write-Host "  ║                                   ║" -ForegroundColor DarkYellow
Write-Host "  ║      XIXERO INSTALLER             ║" -ForegroundColor DarkYellow
Write-Host "  ║      Local AI Gateway             ║" -ForegroundColor DarkYellow
Write-Host "  ║                                   ║" -ForegroundColor DarkYellow
Write-Host "  ╚═══════════════════════════════════╝" -ForegroundColor DarkYellow
Write-Host ""

# ─── Step 1: Prerequisites ───
Write-Step 1 5 "Checking system requirements..."

# OS check
if (-not $IsWindows -and $env:OS -ne "Windows_NT") {
    Write-Err "This installer is for Windows only."
    Write-Host "  For Linux/macOS, download from GitHub Releases." -ForegroundColor Gray
    exit 1
}
Write-Info "Windows detected"

# PowerShell version
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -lt 5) {
    Write-Err "PowerShell 5.0+ required (you have $($psVer.Major).$($psVer.Minor))"
    Write-Host "  Update: https://aka.ms/PSWindows" -ForegroundColor Cyan
    exit 1
}
Write-Info "PowerShell $($psVer.Major).$($psVer.Minor)"

# TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Info "TLS 1.2 enabled"

# Internet
try {
    $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Info "Internet connection OK"
} catch {
    Write-Err "Cannot reach github.com"
    Write-Host "  Check your internet connection and try again." -ForegroundColor Gray
    exit 1
}

# Disk space (need at least 50MB)
$drive = (Split-Path $env:LOCALAPPDATA -Qualifier)
$freeGB = [math]::Round((Get-PSDrive ($drive -replace ':','') | Select-Object -ExpandProperty Free) / 1GB, 1)
if ($freeGB -lt 0.1) {
    Write-Err "Not enough disk space (${freeGB}GB free, need 50MB+)"
    exit 1
}
Write-Info "Disk space: ${freeGB}GB free"

Write-OK "All checks passed"

# ─── Step 2: Check existing installation ───
Write-Step 2 5 "Checking existing installation..."

$isUpgrade = $false
if (Test-Path $exePath) {
    $isUpgrade = $true
    try {
        $currentVer = & $exePath version 2>&1
        Write-Info "Found existing: $currentVer"
    } catch {
        Write-Info "Found existing binary (version unknown)"
    }
    Write-Info "Will upgrade in place"
} else {
    Write-Info "Fresh installation"
}

# ─── Step 3: Download binary ───
Write-Step 3 5 "Downloading Xixero..."

# Create install directory
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

$downloaded = $false

# Try GitHub Releases API
try {
    $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
    $release = Invoke-RestMethod $apiUrl -TimeoutSec 15 -ErrorAction Stop
    $version = $release.tag_name

    Write-Info "Latest release: $version"

    # Find Windows amd64 binary
    $asset = $release.assets | Where-Object {
        $_.name -like "*windows*amd64*" -or
        $_.name -like "*windows*x64*" -or
        ($_.name -like "xixero*" -and $_.name -like "*.exe")
    } | Select-Object -First 1

    if (-not $asset) {
        # Try any windows asset
        $asset = $release.assets | Where-Object { $_.name -like "*windows*" } | Select-Object -First 1
    }

    if ($asset) {
        Write-Info "Downloading $($asset.name) ($([math]::Round($asset.size / 1MB, 1))MB)..."

        # Backup existing binary
        if ($isUpgrade) {
            Copy-Item $exePath "$exePath.bak" -Force -ErrorAction SilentlyContinue
        }

        # Download with progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $exePath -UseBasicParsing -ErrorAction Stop
        $ProgressPreference = 'Continue'

        $downloaded = $true
        Write-OK "Downloaded $version"
    } else {
        Write-Info "No Windows binary in release assets"
    }
} catch {
    $errMsg = $_.Exception.Message
    if ($errMsg -like "*404*") {
        Write-Info "No releases available yet"
    } else {
        Write-Info "Could not reach releases: $errMsg"
    }
}

# If download failed, show clear message
if (-not $downloaded) {
    if ($isUpgrade) {
        Write-Host ""
        Write-Host "  No new release available. Keeping current installation." -ForegroundColor DarkYellow
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────┐" -ForegroundColor DarkYellow
        Write-Host "  │                                                  │" -ForegroundColor DarkYellow
        Write-Host "  │  Binary not available for download yet.          │" -ForegroundColor White
        Write-Host "  │                                                  │" -ForegroundColor DarkYellow
        Write-Host "  │  The release may not be published yet, or the   │" -ForegroundColor DarkGray
        Write-Host "  │  repository may be private.                      │" -ForegroundColor DarkGray
        Write-Host "  │                                                  │" -ForegroundColor DarkYellow
        Write-Host "  │  What to do:                                     │" -ForegroundColor White
        Write-Host "  │  1. Ask the admin for the xixero.exe binary     │" -ForegroundColor White
        Write-Host "  │  2. Place it in:                                 │" -ForegroundColor White
        Write-Host "  │     $installDir" -ForegroundColor Cyan
        Write-Host "  │  3. Run this installer again to set up PATH     │" -ForegroundColor White
        Write-Host "  │                                                  │" -ForegroundColor DarkYellow
        Write-Host "  │  Or check: github.com/$repo/releases" -ForegroundColor Cyan
        Write-Host "  │                                                  │" -ForegroundColor DarkYellow
        Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor DarkYellow
        Write-Host ""
    }
}

# ─── Step 4: Configure PATH ───
Write-Step 4 5 "Configuring system PATH..."

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    $env:Path = "$env:Path;$installDir"
    Write-OK "Added to PATH"
} else {
    Write-Info "Already in PATH"
}

# ─── Step 5: Verify ───
Write-Step 5 5 "Verifying installation..."

if (Test-Path $exePath) {
    $fileSize = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
    Write-Info "Binary size: ${fileSize}MB"

    try {
        $verOutput = (& $exePath version 2>&1) -join " "
        Write-Info "Version: $verOutput"
    } catch {
        Write-Info "Binary exists but version check failed"
    }

    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                                           ║" -ForegroundColor Green
    if ($isUpgrade) {
        Write-Host "  ║      UPGRADE COMPLETE!                    ║" -ForegroundColor Green
    } else {
        Write-Host "  ║      INSTALLATION COMPLETE!               ║" -ForegroundColor Green
    }
    Write-Host "  ║                                           ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Location : " -NoNewline -ForegroundColor DarkGray
    Write-Host $installDir -ForegroundColor White
    if ($version) {
        Write-Host "  Version  : " -NoNewline -ForegroundColor DarkGray
        Write-Host $version -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  ┌─ Getting Started ─────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  1. Open a NEW terminal                    │" -ForegroundColor White
    Write-Host "  │     (to refresh PATH)                      │" -ForegroundColor DarkGray
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  2. Activate your license:                 │" -ForegroundColor White
    Write-Host "  │     xixero activate YOUR-LICENSE-KEY       │" -ForegroundColor Yellow
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  3. Start the gateway:                     │" -ForegroundColor White
    Write-Host "  │     xixero start                           │" -ForegroundColor Yellow
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  │  4. Configure your IDE to use:             │" -ForegroundColor White
    Write-Host "  │     http://localhost:7860/v1                │" -ForegroundColor Yellow
    Write-Host "  │                                            │" -ForegroundColor Cyan
    Write-Host "  └────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  No Go, Python, or Node.js required." -ForegroundColor DarkGray
    Write-Host "  Xixero is a single binary - just run it." -ForegroundColor DarkGray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor DarkYellow
    Write-Host "  ║      PATH CONFIGURED                      ║" -ForegroundColor DarkYellow
    Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Install directory ready: $installDir" -ForegroundColor White
    Write-Host "  Place xixero.exe there, then run:" -ForegroundColor DarkGray
    Write-Host "    xixero start" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Re-run installer when release is available:" -ForegroundColor DarkGray
    Write-Host "    irm https://jinkaka98.github.io/install.ps1 | iex" -ForegroundColor Cyan
    Write-Host ""
}
