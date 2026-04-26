# ═══════════════════════════════════════════
#  Xixero Installer for Windows
#  https://jinkaka98.github.io
# ═══════════════════════════════════════════

$repo = "jinkaka98/xixero"
$installDir = "$env:LOCALAPPDATA\xixero"

# ─── Header ───
Write-Host ""
Write-Host "  ╔═══════════════════════════╗" -ForegroundColor DarkYellow
Write-Host "  ║    Xixero Installer       ║" -ForegroundColor DarkYellow
Write-Host "  ║    Local AI               ║" -ForegroundColor DarkYellow
Write-Host "  ╚═══════════════════════════╝" -ForegroundColor DarkYellow
Write-Host ""

# ─── Step 1: Prerequisites ───
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

# Check PowerShell version
$psVer = $PSVersionTable.PSVersion.Major
if ($psVer -lt 5) {
    Write-Host "  ERROR: PowerShell 5+ required (you have $psVer)" -ForegroundColor Red
    Write-Host "  Update: https://aka.ms/PSWindows" -ForegroundColor Gray
    exit 1
}
Write-Host "       PowerShell $psVer" -ForegroundColor DarkGray

# Force TLS 1.2 (required for GitHub API)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "       TLS 1.2 enabled" -ForegroundColor DarkGray

# Check internet connectivity
try {
    $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "       Internet OK" -ForegroundColor DarkGray
} catch {
    Write-Host "  ERROR: Cannot reach github.com" -ForegroundColor Red
    Write-Host "  Check your internet connection and try again." -ForegroundColor Gray
    exit 1
}

Write-Host "       All checks passed" -ForegroundColor Green

# ─── Step 2: Check latest version ───
Write-Host "[2/5] Checking latest version..." -ForegroundColor Yellow

$release = $null
$version = $null
$downloadUrl = $null

try {
    $release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -TimeoutSec 15 -ErrorAction Stop
    $version = $release.tag_name
    Write-Host "       Latest: $version" -ForegroundColor Green

    # Find Windows binary
    $asset = $release.assets | Where-Object {
        $_.name -like "*windows*amd64*" -or $_.name -like "*windows*x64*" -or $_.name -match "xixero.*\.exe$"
    } | Select-Object -First 1

    if ($asset) {
        $downloadUrl = $asset.browser_download_url
        Write-Host "       Binary: $($asset.name)" -ForegroundColor DarkGray
    }
} catch {
    Write-Host "       No releases published yet" -ForegroundColor DarkYellow
}

# ─── Step 3: Download or build ───
Write-Host "[3/5] Preparing binary..." -ForegroundColor Yellow

# Create install directory
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
$exePath = "$installDir\xixero.exe"

if ($downloadUrl) {
    # Download from GitHub Releases
    Write-Host "       Downloading from GitHub Releases..." -ForegroundColor DarkGray
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing -ErrorAction Stop
        Write-Host "       Downloaded to $exePath" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: Download failed - $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    # No release available - check if Go is installed to build from source
    Write-Host "       No release binary available." -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────┐" -ForegroundColor DarkYellow
    Write-Host "  │  No release has been published yet.         │" -ForegroundColor DarkYellow
    Write-Host "  │                                             │" -ForegroundColor DarkYellow
    Write-Host "  │  Options:                                   │" -ForegroundColor DarkYellow
    Write-Host "  │  1. Wait for the first release              │" -ForegroundColor White
    Write-Host "  │  2. Build from source (requires Go 1.21+):  │" -ForegroundColor White
    Write-Host "  │                                             │" -ForegroundColor DarkYellow
    Write-Host "  │     git clone https://github.com/$repo" -ForegroundColor Cyan
    Write-Host "  │     cd xixero                               │" -ForegroundColor Cyan
    Write-Host "  │     go build -o bin\xixero.exe .\cmd\xixero │" -ForegroundColor Cyan
    Write-Host "  │                                             │" -ForegroundColor DarkYellow
    Write-Host "  │  3. Copy binary manually to:                │" -ForegroundColor White
    Write-Host "  │     $installDir" -ForegroundColor Cyan
    Write-Host "  │                                             │" -ForegroundColor DarkYellow
    Write-Host "  └─────────────────────────────────────────────┘" -ForegroundColor DarkYellow
    Write-Host ""

    # Still set up PATH so when binary is placed manually it works
    Write-Host "       Setting up install directory anyway..." -ForegroundColor DarkGray

    # Check if binary already exists (manual install)
    if (Test-Path $exePath) {
        Write-Host "       Found existing binary at $exePath" -ForegroundColor Green
    } else {
        # Check if Go is available for building from source
        $goCmd = Get-Command go -ErrorAction SilentlyContinue
        if ($goCmd) {
            Write-Host "       Go detected: $($goCmd.Source)" -ForegroundColor DarkGray
            $buildChoice = Read-Host "       Build from source? (y/n)"
            if ($buildChoice -eq 'y') {
                Write-Host "       Cloning repository..." -ForegroundColor DarkGray
                $tempDir = "$env:TEMP\xixero-build"
                if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }

                try {
                    git clone "https://github.com/$repo.git" $tempDir 2>&1 | Out-Null
                    Push-Location $tempDir
                    Write-Host "       Building..." -ForegroundColor DarkGray
                    go build -o $exePath ./cmd/xixero 2>&1
                    Pop-Location
                    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

                    if (Test-Path $exePath) {
                        Write-Host "       Built successfully!" -ForegroundColor Green
                    } else {
                        Write-Host "  ERROR: Build failed" -ForegroundColor Red
                        exit 1
                    }
                } catch {
                    Pop-Location -ErrorAction SilentlyContinue
                    Write-Host "  ERROR: Build failed - $($_.Exception.Message)" -ForegroundColor Red
                    exit 1
                }
            } else {
                Write-Host "       Skipped. Place xixero.exe in $installDir manually." -ForegroundColor DarkGray
            }
        } else {
            Write-Host "       Go not found. Cannot build from source." -ForegroundColor DarkGray
            Write-Host "       Place xixero.exe in $installDir when available." -ForegroundColor DarkGray
        }
    }
}

# ─── Step 4: Configure PATH ───
Write-Host "[4/5] Configuring PATH..." -ForegroundColor Yellow
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    $env:Path = "$env:Path;$installDir"
    Write-Host "       Added to PATH" -ForegroundColor Green
} else {
    Write-Host "       Already in PATH" -ForegroundColor Green
}

# ─── Step 5: Verify ───
Write-Host "[5/5] Verifying installation..." -ForegroundColor Yellow
if (Test-Path $exePath) {
    try {
        $verOutput = & $exePath version 2>&1
        Write-Host "       $verOutput" -ForegroundColor Green
    } catch {
        Write-Host "       Binary exists but could not run version check" -ForegroundColor DarkYellow
    }

    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║    Installation complete!              ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Location : $installDir" -ForegroundColor White
    if ($version) {
        Write-Host "  Version  : $version" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  Quick Start:" -ForegroundColor Cyan
    Write-Host "    1. Open a NEW terminal (to refresh PATH)" -ForegroundColor White
    Write-Host "    2. Run: " -NoNewline -ForegroundColor White
    Write-Host "xixero activate <YOUR-LICENSE-KEY>" -ForegroundColor Cyan
    Write-Host "    3. Run: " -NoNewline -ForegroundColor White
    Write-Host "xixero start" -ForegroundColor Cyan
    Write-Host "    4. Open: " -NoNewline -ForegroundColor White
    Write-Host "http://localhost:7860" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════╗" -ForegroundColor DarkYellow
    Write-Host "  ║    PATH configured, binary pending    ║" -ForegroundColor DarkYellow
    Write-Host "  ╚═══════════════════════════════════════╝" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Install directory: $installDir" -ForegroundColor White
    Write-Host "  PATH is ready. Place xixero.exe in the directory above." -ForegroundColor White
    Write-Host ""
    Write-Host "  When a release is published, run this installer again:" -ForegroundColor Gray
    Write-Host "    irm https://jinkaka98.github.io/install.ps1 | iex" -ForegroundColor Cyan
    Write-Host ""
}
