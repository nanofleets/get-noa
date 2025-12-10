# Usage: iwr -useb https://raw.githubusercontent.com/nanofleets/get-noa/main/install.ps1 | iex
$ErrorActionPreference = "Stop"

# Config
$InstallDir = "$env:LOCALAPPDATA\noa"
$ExePath    = "$InstallDir\noa.exe"
$Url        = "https://github.com/nanofleets/get-noa/releases/latest/download/noa-windows-amd64.exe"

# 1. Create Directory
if (!(Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

# 2. Download
Write-Host "Downloading $Url"
Write-Host "       to $ExePath"

try {
    Invoke-WebRequest -Uri $Url -OutFile $ExePath
} catch {
    Write-Error "Download failed. Check your internet or repository settings."
    exit 1
}

# 3. Unblock Binary (Crucial for SmartScreen)
Unblock-File -Path $ExePath

# 4. Path Management
# Add to User Environment (Permanent)
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
}

# Add to Current Session (Immediate use)
if ($env:Path -notlike "*$InstallDir*") {
    $env:Path = "$env:Path;$InstallDir"
}

Write-Host ""
Write-Host "Finished. Run 'noa version' to verify."