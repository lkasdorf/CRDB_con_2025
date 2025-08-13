# CRDB Converter Windows Installer

This directory contains the Windows installer configuration and build scripts for the CRDB Zoho Converter.

## 📦 What's Included

- **`crdb-converter-setup.iss`** - Inno Setup script for the installer
- **`build-installer.bat`** - Windows batch script to build the installer
- **`build-installer.ps1`** - PowerShell script to build the installer (recommended)
- **`README.md`** - This documentation file

## 🛠️ Prerequisites

### 1. Inno Setup 6.x
Download and install Inno Setup from: https://jrsoftware.org/isinfo.php

**Important:** Make sure to add Inno Setup to your PATH during installation.

### 2. Built Executables
Before building the installer, you need to create the Windows executables:

```powershell
# Install PyInstaller
pip install pyinstaller

# Build the main converter
pyinstaller --onefile --name crdb-convert convert_crdb_to_zoho.py

# Build the inspector tool
pyinstaller --onefile --name crdb-inspect _inspect_xls.py
```

The executables will be created in the `dist/` directory.

## 🚀 Building the Installer

### Option 1: PowerShell Script (Recommended)
```powershell
# Navigate to the installer directory
cd installer

# Build the installer
.\build-installer.ps1

# Or build silently (no user prompts)
.\build-installer.ps1 -Silent
```

### Option 2: Batch Script
```cmd
# Navigate to the installer directory
cd installer

# Build the installer
build-installer.bat
```

### Option 3: Manual Build
```cmd
# Navigate to the installer directory
cd installer

# Build using Inno Setup directly
iscc crdb-converter-setup.iss
```

## 📁 Output

The installer will be created in the `dist/` directory as:
```
crdb-converter-setup-0.2.6.exe
```

## ✨ Installer Features

### Automatic Installation
- Installs to `Program Files\CRDB Zoho Converter`
- Creates Start Menu shortcuts
- Optional desktop and quick launch icons

### PATH Integration
- **Admin Mode**: Adds to system PATH (all users)
- **User Mode**: Adds to user PATH (current user only)
- Automatically handles PATH modifications

### Documentation
- Includes README.md, LICENSE, and ABOUT.md
- Shows README after installation
- Provides uninstall capability

### Multi-language Support
- English and German interfaces
- Localized messages and descriptions

## 🔧 Customization

### Version Updates
To update the version, modify these lines in `crdb-converter-setup.iss`:

```pascal
#define MyAppVersion "0.2.6"
```

### Company Information
Update the publisher information:

```pascal
#define MyAppPublisher "Your Company Name"
#define MyAppURL "https://your-website.com"
```

### App ID
Generate a unique App ID for your application:

```pascal
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
```

## 📋 Build Process

1. **Check Prerequisites**
   - Verify Inno Setup is installed
   - Ensure executables exist in `dist/`

2. **Build Installer**
   - Run the build script
   - Check for errors in the output

3. **Test Installation**
   - Run the generated installer
   - Verify PATH modifications
   - Test uninstallation

## 🐛 Troubleshooting

### "iscc not found"
- Install Inno Setup and add to PATH
- Restart your command prompt/PowerShell

### "Executables not found"
- Build the PyInstaller executables first
- Check the `dist/` directory exists

### Build Errors
- Verify all source files exist
- Check file paths in the .iss file
- Ensure sufficient disk space

## 📚 Additional Resources

- [Inno Setup Documentation](https://jrsoftware.org/ishelp/)
- [Inno Setup Examples](https://github.com/jrsoftware/issrc/tree/main/Examples)
- [PyInstaller Documentation](https://pyinstaller.org/en/stable/)

## 🤝 Contributing

When modifying the installer:

1. Test on clean Windows installations
2. Verify PATH modifications work correctly
3. Test both admin and user installation modes
4. Update version numbers consistently
5. Document any new features or changes
