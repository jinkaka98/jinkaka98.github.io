$baseUrl = "https://jinkaka98.github.io/releases"
$installDir = "$env:LOCALAPPDATA\xixero1445"
$exePath = "$installDir\xixero.exe"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "  =====================================" -ForegroundColor DarkYellow
Write-Host "       XIXERO INSTALLER" -ForegroundColor DarkYellow
Write-Host "       Local AI Gateway" -ForegroundColor DarkYellow
Write-Host "  =====================================" -ForegroundColor DarkYellow
Write-Host ""

# --- Step 1: System Check ---
Write-Host "[1/5] Checking system..." -ForegroundColor Yellow

if ($env:OS -ne "Windows_NT") {
    Write-Host "  ERROR: Windows only." -ForegroundColor Red; exit 1
}

$psv = $PSVersionTable.PSVersion
if ($psv.Major -lt 5) {
    Write-Host "  ERROR: PowerShell 5+ required." -ForegroundColor Red; exit 1
}

try {
    $null = Invoke-WebRequest "https://jinkaka98.github.io" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
} catch {
    Write-Host "  ERROR: No internet." -ForegroundColor Red; exit 1
}

Write-Host "       OK (PS $($psv.Major).$($psv.Minor), TLS 1.2, Internet)" -ForegroundColor Green

# --- Step 2: Check Version ---
Write-Host "[2/5] Checking latest version..." -ForegroundColor Yellow

$version = $null
$downloadUrl = $null

try {
    $latest = Invoke-RestMethod "$baseUrl/latest.json" -TimeoutSec 15 -ErrorAction Stop
    $version = $latest.version
    $downloadUrl = $latest.binaries.'windows-amd64'.url
    $fileSize = $latest.binaries.'windows-amd64'.size
    $sizeMB = [math]::Round($fileSize / 1MB, 1)
    Write-Host "       v$version ($sizeMB MB)" -ForegroundColor Green
} catch {
    $downloadUrl = "$baseUrl/xixero-windows-amd64.exe"
    Write-Host "       Trying direct download..." -ForegroundColor DarkGray
}

if (Test-Path $exePath) {
    try {
        $cur = (& $exePath version 2>&1) -join " "
        Write-Host "       Installed: $cur" -ForegroundColor DarkGray
    } catch {}
}

# --- Step 3: Download ---
Write-Host "[3/5] Downloading..." -ForegroundColor Yellow

New-Item -ItemType Directory -Path $installDir -Force | Out-Null

if ($downloadUrl) {
    if (Test-Path $exePath) {
        Copy-Item $exePath "$exePath.bak" -Force -ErrorAction SilentlyContinue
    }

    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
        $ProgressPreference = 'Continue'
        $dl = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
        Write-Host "       Downloaded ($dl MB)" -ForegroundColor Green
    } catch {
        $msg = $_.Exception.Message
        if ($msg -like "*404*") {
            Write-Host "  ERROR: Binary not available yet." -ForegroundColor Red
            Write-Host "  Ask admin for the binary or try again later." -ForegroundColor DarkGray
        } else {
            Write-Host "  ERROR: $msg" -ForegroundColor Red
            if (Test-Path "$exePath.bak") {
                Move-Item "$exePath.bak" $exePath -Force
                Write-Host "       Restored previous version." -ForegroundColor DarkGray
            }
        }
    }
}

# --- Step 4: PATH ---
Write-Host "[4/5] Configuring PATH..." -ForegroundColor Yellow

# Detect old xixero in PATH
$conflicts = Get-Command xixero -All -ErrorAction SilentlyContinue | Where-Object {
    $_.Source -ne $exePath -and $_.Source -notlike "$installDir*"
}

if ($conflicts) {
    Write-Host ""
    Write-Host "  WARNING: Old 'xixero' found:" -ForegroundColor Red
    foreach ($c in $conflicts) {
        Write-Host "    $($c.Source)" -ForegroundColor Yellow
    }
    Write-Host "  Fixing PATH priority..." -ForegroundColor White

    foreach ($c in $conflicts) {
        $dir = Split-Path $c.Source -Parent
        $uP = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($uP -like "*$dir*") {
            $uP = ($uP -split ';' | Where-Object { $_ -ne $dir }) -join ';'
            [Environment]::SetEnvironmentVariable("Path", $uP, "User")
            Write-Host "    Removed from User PATH" -ForegroundColor DarkGray
        }
        $mP = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($mP -like "*$dir*") {
            try {
                $mP = ($mP -split ';' | Where-Object { $_ -ne $dir }) -join ';'
                [Environment]::SetEnvironmentVariable("Path", $mP, "Machine")
                Write-Host "    Removed from System PATH" -ForegroundColor DarkGray
            } catch {
                Write-Host "    System PATH needs admin fix:" -ForegroundColor DarkYellow
                Write-Host "    Remove: $dir" -ForegroundColor Yellow
            }
        }
    }
    Write-Host ""
}

# Add our dir to PATH (prepend for priority)
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$installDir;$userPath", "User")
    Write-Host "       Added to PATH" -ForegroundColor Green
} else {
    Write-Host "       Already in PATH" -ForegroundColor DarkGray
}

$env:Path = "$installDir;" + (($env:Path -split ';' | Where-Object { $_ -ne $installDir }) -join ';')

# --- Step 5: Verify ---
Write-Host "[5/5] Verifying..." -ForegroundColor Yellow

if (Test-Path $exePath) {
    try {
        $v = (& $exePath version 2>&1) -join " "
        Write-Host "       $v" -ForegroundColor Green
    } catch {
        Write-Host "       Binary OK" -ForegroundColor Green
    }

    Remove-Item "$exePath.bak" -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "  =====================================" -ForegroundColor Green
    Write-Host "       INSTALLATION COMPLETE" -ForegroundColor Green
    Write-Host "  =====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Location : $installDir" -ForegroundColor White
    if ($version) { Write-Host "  Version  : v$version" -ForegroundColor White }
    Write-Host ""
    Write-Host "  --- Quick Start ---" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Open a NEW terminal" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Activate license:" -ForegroundColor White
    Write-Host "     xixero activate YOUR-LICENSE-KEY" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  3. Start gateway:" -ForegroundColor White
    Write-Host "     xixero start" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  4. Browser opens automatically at:" -ForegroundColor White
    Write-Host "     http://localhost:7860" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  Binary not available yet." -ForegroundColor DarkYellow
    Write-Host "  Run installer again when release is ready:" -ForegroundColor DarkGray
    Write-Host "  irm https://jinkaka98.github.io/install.ps1 | iex" -ForegroundColor Cyan
    Write-Host ""
}
