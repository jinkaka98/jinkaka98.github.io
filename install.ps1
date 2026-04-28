# Xixero Installation Script
# Downloads and installs the latest version of Xixero

$ErrorActionPreference = "Stop"

Write-Host "🚀 Xixero Installer" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  Administrator privileges required for installation." -ForegroundColor Yellow
    Write-Host "   Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Check system requirements
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host "❌ Windows 10 or later is required." -ForegroundColor Red
    exit 1
}

Write-Host "✅ System requirements met" -ForegroundColor Green

# Download latest release info
Write-Host "📡 Fetching latest release information..." -ForegroundColor Yellow

try {
    $releaseInfo = Invoke-RestMethod -Uri "https://jinkaka98.github.io/releases/latest.json"
    $version = $releaseInfo.version
    $downloadUrl = $releaseInfo.installer.url
    $fileName = $releaseInfo.installer.file
    
    Write-Host "📦 Latest version: v$version" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to fetch release information: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create temp directory
$tempDir = Join-Path $env:TEMP "xixero-install"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Download installer
$installerPath = Join-Path $tempDir $fileName
Write-Host "⬇️  Downloading Xixero v$version..." -ForegroundColor Yellow

try {
    $progressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
    Write-Host "✅ Download completed" -ForegroundColor Green
} catch {
    Write-Host "❌ Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify file exists and has reasonable size
if (-not (Test-Path $installerPath)) {
    Write-Host "❌ Installer file not found after download" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $installerPath).Length
if ($fileSize -lt 1MB) {
    Write-Host "❌ Downloaded file appears to be corrupted (too small)" -ForegroundColor Red
    exit 1
}

Write-Host "📁 File size: $([math]::Round($fileSize / 1MB, 1)) MB" -ForegroundColor Green

# Run installer
Write-Host "🔧 Running installer..." -ForegroundColor Yellow
Write-Host "   (Installation window will appear shortly)" -ForegroundColor Gray

try {
    Start-Process -FilePath $installerPath -Wait
    Write-Host "✅ Installation completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Cleanup
Write-Host "🧹 Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item $tempDir -Recurse -Force

Write-Host ""
Write-Host "🎉 Xixero v$version has been installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Launch Xixero from your Start Menu" -ForegroundColor White
Write-Host "2. Configure your AI provider settings" -ForegroundColor White
Write-Host "3. Point your IDE to localhost:1445" -ForegroundColor White
Write-Host ""
Write-Host "Need help? Join our Discord: https://discord.gg/TFErxnnEfY" -ForegroundColor Gray