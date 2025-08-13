# CRDB Zoho Converter - Complete Windows Cleanup Script
# Run this script as Administrator for complete cleanup
# This script removes all traces of CRDB Zoho Converter from your system

param(
    [switch]$Force,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Continue"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running as Administrator
if (-not (Test-Admin)) {
    Write-Error "This script requires Administrator privileges for complete cleanup."
    Write-Info "Please run PowerShell as Administrator and try again."
    Write-Info "Some cleanup operations will be skipped without admin rights."
    $adminMode = $false
} else {
    $adminMode = $true
    Write-Success "Running with Administrator privileges - full cleanup enabled"
}

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "CRDB Zoho Converter - Windows Cleanup" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

if (-not $Force) {
    Write-Warning "This script will remove ALL traces of CRDB Zoho Converter from your system."
    Write-Warning "This includes:"
    Write-Warning "  - Program files and installation directory"
    Write-Warning "  - PATH environment variables"
    Write-Warning "  - Start Menu shortcuts"
    Write-Warning "  - User-specific files"
    Write-Warning "  - Build artifacts"
    Write-Host ""
    
    $confirmation = Read-Host "Are you sure you want to continue? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Info "Cleanup cancelled by user."
        exit 0
    }
}

Write-Info "Starting cleanup process..."

# 1. Remove from PATH environment variables
Write-Info "Cleaning PATH environment variables..."
$paths = @("User", "Machine")
foreach ($scope in $paths) {
    try {
        $oldPath = [Environment]::GetEnvironmentVariable("Path", $scope)
        if ($oldPath) {
            $pathEntries = $oldPath -split ';'
            $filteredEntries = $pathEntries | Where-Object { 
                $_ -and $_ -notlike "*CRDB*" -and $_ -notlike "*crdb*" -and $_ -notlike "*Zoho*" -and $_ -notlike "*zoho*"
            }
            $newPath = $filteredEntries -join ';'
            
            if ($newPath -ne $oldPath) {
                [Environment]::SetEnvironmentVariable("Path", $newPath, $scope)
                Write-Success "Cleaned PATH for $scope scope"
                if ($Verbose) {
                    Write-Info "Removed entries:"
                    ($pathEntries | Where-Object { $_ -like "*CRDB*" -or $_ -like "*crdb*" -or $_ -like "*Zoho*" -or $_ -like "*zoho*" }) | ForEach-Object { Write-Info "  $_" }
                }
            } else {
                Write-Info "No CRDB-related entries found in $scope PATH"
            }
        }
    } catch {
        if ($adminMode) {
            Write-Error "Could not clean PATH for $scope scope: $($_.Exception.Message)"
        } else {
            Write-Warning "Could not clean PATH for $scope scope (requires admin rights)"
        }
    }
}

# 2. Remove installation directory
Write-Info "Removing installation directory..."
$installPaths = @(
    "C:\Program Files\CRDB Zoho Converter",
    "C:\Program Files (x86)\CRDB Zoho Converter"
)

foreach ($installPath in $installPaths) {
    if (Test-Path $installPath) {
        try {
            Remove-Item -Recurse -Force $installPath
            Write-Success "Removed installation directory: $installPath"
        } catch {
            Write-Error "Could not remove installation directory $installPath`: $($_.Exception.Message)"
        }
    } else {
        Write-Info "Installation directory not found: $installPath"
    }
}

# 3. Remove user-specific files
Write-Info "Removing user-specific files..."
$userPaths = @(
    "$env:USERPROFILE\bin\crdb-convert.exe",
    "$env:USERPROFILE\bin\crdb-inspect.exe",
    "$env:APPDATA\CRDB Zoho Converter",
    "$env:LOCALAPPDATA\CRDB Zoho Converter"
)

foreach ($userPath in $userPaths) {
    if (Test-Path $userPath) {
        try {
            Remove-Item -Recurse -Force $userPath
            Write-Success "Removed user file: $userPath"
        } catch {
            Write-Error "Could not remove user file $userPath`: $($_.Exception.Message)"
        }
    }
}

# 4. Remove Start Menu shortcuts
Write-Info "Removing Start Menu shortcuts..."
$startMenuPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\CRDB Zoho Converter",
    "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\CRDB Zoho Converter"
)

foreach ($startMenuPath in $startMenuPaths) {
    if (Test-Path $startMenuPath) {
        try {
            Remove-Item -Recurse -Force $startMenuPath
            Write-Success "Removed Start Menu shortcuts: $startMenuPath"
        } catch {
            Write-Error "Could not remove Start Menu shortcuts $startMenuPath`: $($_.Exception.Message)"
        }
    }
}

# 5. Remove desktop shortcuts
Write-Info "Removing desktop shortcuts..."
$desktopShortcuts = @(
    "$env:USERPROFILE\Desktop\CRDB Zoho Converter.lnk",
    "$env:PUBLIC\Desktop\CRDB Zoho Converter.lnk"
)

foreach ($shortcut in $desktopShortcuts) {
    if (Test-Path $shortcut) {
        try {
            Remove-Item -Force $shortcut
            Write-Success "Removed desktop shortcut: $shortcut"
        } catch {
            Write-Error "Could not remove desktop shortcut $shortcut`: $($_.Exception.Message)"
        }
    }
}

# 6. Remove build artifacts (if in current directory)
Write-Info "Removing build artifacts..."
$buildPaths = @("dist", "build", "*.spec")
foreach ($buildPath in $buildPaths) {
    if (Test-Path $buildPath) {
        try {
            if ((Get-Item $buildPath) -is [System.IO.DirectoryInfo]) {
                Remove-Item -Recurse -Force $buildPath
            } else {
                Remove-Item -Force $buildPath
            }
            Write-Success "Removed build artifact: $buildPath"
        } catch {
            Write-Error "Could not remove build artifact $buildPath`: $($_.Exception.Message)"
        }
    }
}

# 7. Remove registry entries (if any)
Write-Info "Cleaning registry entries..."
$registryPaths = @(
    "HKCU:\Software\CRDB Zoho Converter",
    "HKLM:\Software\CRDB Zoho Converter",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\CRDB Zoho Converter",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\CRDB Zoho Converter"
)

foreach ($regPath in $registryPaths) {
    if (Test-Path $regPath) {
        try {
            Remove-Item -Recurse -Force $regPath
            Write-Success "Removed registry entry: $regPath"
        } catch {
            Write-Error "Could not remove registry entry $regPath`: $($_.Exception.Message)"
        }
    }
}

# 8. Final verification
Write-Host ""
Write-Info "Performing final verification..."

$remainingItems = @()
$checkPaths = @(
    "C:\Program Files\CRDB Zoho Converter",
    "C:\Program Files (x86)\CRDB Zoho Converter",
    "$env:USERPROFILE\bin\crdb-convert.exe",
    "$env:APPDATA\CRDB Zoho Converter"
)

foreach ($checkPath in $checkPaths) {
    if (Test-Path $checkPath) {
        $remainingItems += $checkPath
    }
}

if ($remainingItems.Count -eq 0) {
    Write-Success "All CRDB Zoho Converter files have been successfully removed!"
} else {
    Write-Warning "Some items could not be removed:"
    foreach ($item in $remainingItems) {
        Write-Warning "  - $item"
    }
    Write-Info "You may need to manually remove these items or restart your computer."
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Cleanup process completed!" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

if (-not $adminMode) {
    Write-Warning "Some cleanup operations were skipped due to lack of Administrator privileges."
    Write-Info "To complete the cleanup, restart this script as Administrator."
}

Write-Info "It's recommended to restart your computer to ensure all changes take effect."
