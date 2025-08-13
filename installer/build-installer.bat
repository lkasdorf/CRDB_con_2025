@echo off
echo CRDB Converter Installer Builder
echo ========================================

echo Checking Inno Setup...
where iscc >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Inno Setup (iscc) not found in PATH
    echo Please install Inno Setup 6.x from: https://jrsoftware.org/isinfo.php
    pause
    exit /b 1
)

echo Found Inno Setup
echo.

echo Checking executables...
if not exist "..\dist\crdb-convert.exe" (
    echo ERROR: crdb-convert.exe not found in ..\dist\
    echo Please build the executables first using PyInstaller
    pause
    exit /b 1
)

if not exist "..\dist\crdb-inspect.exe" (
    echo ERROR: crdb-inspect.exe not found in ..\dist\
    echo Please build the executables first using PyInstaller
    pause
    exit /b 1
)

echo Found executables
echo.

echo Building installer...
iscc crdb-converter-setup.iss

if %errorlevel% equ 0 (
    echo SUCCESS: Installer built successfully!
    echo Output: ..\dist\crdb-converter-setup-0.2.6.exe
) else (
    echo ERROR: Failed to build installer
)

pause
