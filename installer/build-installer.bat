@echo off
REM CRDB Converter Installer Builder
REM This script builds the Windows installer using Inno Setup
REM Prerequisites: Inno Setup 6.x must be installed

echo ========================================
echo CRDB Converter Installer Builder
echo ========================================

REM Check if Inno Setup is installed
where iscc >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Inno Setup (iscc) not found in PATH
    echo Please install Inno Setup 6.x from: https://jrsoftware.org/isinfo.php
    echo After installation, restart this script
    pause
    exit /b 1
)

REM Check if dist directory exists with executables
if not exist "..\dist\crdb-convert.exe" (
    echo ERROR: crdb-convert.exe not found in ..\dist\
    echo Please build the executables first using PyInstaller:
    echo   pip install pyinstaller
    echo   pyinstaller --onefile --name crdb-convert convert_crdb_to_zoho.py
    echo   pyinstaller --onefile --name crdb-inspect _inspect_xls.py
    pause
    exit /b 1
)

if not exist "..\dist\crdb-inspect.exe" (
    echo ERROR: crdb-inspect.exe not found in ..\dist\
    echo Please build the executables first using PyInstaller
    pause
    exit /b 1
)

echo Found executables in ..\dist\
echo.

REM Create installer directory if it doesn't exist
if not exist "..\dist" mkdir "..\dist"

echo Building installer...
echo.

REM Build the installer
iscc "crdb-converter-setup.iss"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Installer built successfully!
    echo ========================================
    echo.
    echo Output file: ..\dist\crdb-converter-setup-0.2.5.exe
    echo.
    echo You can now distribute this installer to Windows users.
    echo The installer will:
    echo   - Install to Program Files
    echo   - Add to PATH automatically
    echo   - Create Start Menu shortcuts
    echo   - Provide uninstall capability
    echo.
) else (
    echo.
    echo ERROR: Failed to build installer
    echo Check the error messages above
    echo.
)

pause
