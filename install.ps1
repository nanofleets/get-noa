# Usage: iwr -useb https://raw.githubusercontent.com/nanofleets/get-noa/main/install.ps1 | iex
$ErrorActionPreference = "Stop"

# Config
$Repo       = "nanofleets/get-noa"
$InstallDir = "$env:LOCALAPPDATA\noa"
$ExePath    = "$InstallDir\noa.exe"

# 1. Resolve Version (Head request to follow redirect)
try {
    $Resp = Invoke-WebRequest "https://github.com/$Repo/releases/latest" -Method Head
    $Version = ($Resp.BaseResponse.ResponseUri.Segments[-1]).Trim()
} catch {
    $Version = "latest"
}
Write-Host "Found version: $Version"

# 2. Setup
$Url = "https://github.com/$Repo/releases/latest/download/noa-windows-amd64.exe"
if (!(Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

# 3. Download
Write-Host "Downloading $Url"
Write-Host "         to $ExePath"

try {
    Invoke-WebRequest -Uri $Url -OutFile $ExePath
} catch {
    Write-Error "Download failed."
    exit 1
}

# 4. Finalize
Unblock-File -Path $ExePath

# Path Updates
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
}
if ($env:Path -notlike "*$InstallDir*") {
    $env:Path = "$env:Path;$InstallDir"
}

Write-Host "Finished. Run 'noa version' to verify."