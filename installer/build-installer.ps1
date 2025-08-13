# CRDB Converter Installer Builder (PowerShell)
# This script builds the Windows installer using Inno Setup
# Prerequisites: Inno Setup 6.x must be installed

param(
    [switch]$Silent,
    [string]$Version = "0.2.5"
)

# Set error action preference
$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Message)
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

try {
    Write-Header "CRDB Converter Installer Builder"
    
    # Check if Inno Setup is installed
    $isccPath = Get-Command iscc -ErrorAction SilentlyContinue
    if (-not $isccPath) {
        Write-Error "Inno Setup (iscc) not found in PATH"
        Write-Info "Please install Inno Setup 6.x from: https://jrsoftware.org/isinfo.php"
        Write-Info "After installation, restart this script"
        if (-not $Silent) { Read-Host "Press Enter to continue" }
        exit 1
    }
    
    Write-Success "Found Inno Setup at: $($isccPath.Source)"
    
    # Check if dist directory exists with executables
    $distPath = Join-Path (Split-Path $PSScriptRoot -Parent) "dist"
    $mainExe = Join-Path $distPath "crdb-convert.exe"
    $inspectorExe = Join-Path $distPath "crdb-inspect.exe"
    
    if (-not (Test-Path $mainExe)) {
        Write-Error "crdb-convert.exe not found in $distPath"
        Write-Info "Please build the executables first using PyInstaller:"
        Write-Info "  pip install pyinstaller"
        Write-Info "  pyinstaller --onefile --name crdb-convert convert_crdb_to_zoho.py"
        Write-Info "  pyinstaller --onefile --name crdb-inspect _inspect_xls.py"
        if (-not $Silent) { Read-Host "Press Enter to continue" }
        exit 1
    }
    
    if (-not (Test-Path $inspectorExe)) {
        Write-Error "crdb-inspect.exe not found in $distPath"
        Write-Info "Please build the executables first using PyInstaller"
        if (-not $Silent) { Read-Host "Press Enter to continue" }
        exit 1
    }
    
    Write-Success "Found executables in $distPath"
    Write-Host ""
    
    # Create installer directory if it doesn't exist
    if (-not (Test-Path $distPath)) {
        New-Item -ItemType Directory -Path $distPath -Force | Out-Null
    }
    
    Write-Info "Building installer..."
    Write-Host ""
    
    # Get the Inno Setup script path
    $issPath = Join-Path $PSScriptRoot "crdb-converter-setup.iss"
    
    # Build the installer
    $process = Start-Process -FilePath "iscc" -ArgumentList "`"$issPath`"" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host ""
        Write-Header "Installer built successfully!"
        Write-Host ""
        
        $outputFile = Join-Path $distPath "crdb-converter-setup-$Version.exe"
        Write-Success "Output file: $outputFile"
        Write-Host ""
        
        Write-Info "You can now distribute this installer to Windows users."
        Write-Info "The installer will:"
        Write-Info "  - Install to Program Files"
        Write-Info "  - Add to PATH automatically"
        Write-Info "  - Create Start Menu shortcuts"
        Write-Info "  - Provide uninstall capability"
        Write-Host ""
        
        # Open the output directory
        if (-not $Silent) {
            $openFolder = Read-Host "Open output folder? (y/n)"
            if ($openFolder -eq "y" -or $openFolder -eq "Y") {
                Start-Process "explorer.exe" -ArgumentList "/select,`"$outputFile`""
            }
        }
    } else {
        Write-Host ""
        Write-Error "Failed to build installer (Exit Code: $($process.ExitCode))"
        Write-Info "Check the error messages above"
        Write-Host ""
    }
    
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    Write-Host ""
    Write-Info "Stack trace:"
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
} finally {
    if (-not $Silent) {
        Read-Host "Press Enter to continue"
    }
}
