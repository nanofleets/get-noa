# NOA CLI installer script for Windows
# Usage: iwr -useb https://raw.githubusercontent.com/nanofleets/get-noa/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$REPO = "nanofleets/get-noa"
$BINARY_NAME = "noa.exe"
$INSTALL_DIR = "$env:LOCALAPPDATA\Programs\noa"

Write-Host "Installing NOA CLI for Windows..." -ForegroundColor Cyan

# Get latest release version
Write-Host "Fetching latest release..." -ForegroundColor Yellow
try {
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$REPO/releases/latest"
    $version = $releases.tag_name
} catch {
    Write-Host "Error: Could not fetch latest release version" -ForegroundColor Red
    exit 1
}

Write-Host "Latest version: $version" -ForegroundColor Green

# Download URL
$BINARY_FILE = "noa-windows-amd64.exe"
$DOWNLOAD_URL = "https://github.com/$REPO/releases/download/$version/$BINARY_FILE"

Write-Host "Downloading from: $DOWNLOAD_URL" -ForegroundColor Yellow

# Create install directory
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}

$INSTALL_PATH = Join-Path $INSTALL_DIR $BINARY_NAME

# Download binary
try {
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $INSTALL_PATH
} catch {
    Write-Host "Error: Failed to download binary" -ForegroundColor Red
    exit 1
}

# Add to PATH if not already present
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$INSTALL_DIR*") {
    Write-Host "Adding NOA to PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$userPath;$INSTALL_DIR",
        "User"
    )
    $env:Path = "$env:Path;$INSTALL_DIR"
}

Write-Host ""
Write-Host "✓ NOA CLI installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Installation location: $INSTALL_PATH" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
Write-Host "Run 'noa --help' to get started" -ForegroundColor Cyan
