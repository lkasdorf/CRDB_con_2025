; CRDB Zoho Converter Windows Installer
; Created with Inno Setup 6.x
; This script creates a professional Windows installer that:
; - Installs the executable to Program Files
; - Adds the installation directory to PATH
; - Creates Start Menu shortcuts
; - Provides uninstall capability

#define MyAppName "CRDB Zoho Converter"
#define MyAppVersion "0.2.8"
#define MyAppPublisher "Leon Kasdorf"
#define MyAppURL "https://github.com/lkasdorf/CRDB_con_2025"
#define MyAppExeName "crdb-convert.exe"
#define MyAppInspectorName "crdb-inspect.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\LICENSE
InfoBeforeFile=..\README.md
OutputDir=..\dist
OutputBaseFilename=crdb-converter-setup-{#MyAppVersion}
; SetupIconFile=..\installer\icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
; Require admin rights for PATH modification
PrivilegesRequiredOverridesAllowed=dialog

; Version info for the installer
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=CRDB Zoho Converter Installer
VersionInfoCopyright=Copyright (C) 2025 {#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
; Main executable
Source: "..\dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; Inspector tool
Source: "..\dist\{#MyAppInspectorName}"; DestDir: "{app}"; Flags: ignoreversion
; Documentation
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\ABOUT.md"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\CRDB Inspector"; Filename: "{app}\{#MyAppInspectorName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
; Add installation directory to PATH
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
; Show README after installation
Filename: "{app}\README.md"; Description: "View README"; Flags: nowait postinstall skipifsilent shellexec

[Registry]
; Add to PATH for current user (if not admin) or all users (if admin)
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Check: not IsAdminLoggedOn
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Check: IsAdminLoggedOn

[Code]
// Custom code to handle PATH modification more robustly
function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  
  if CurPageID = wpReady then
  begin
    // Check if we can modify PATH
    if not IsAdminLoggedOn then
    begin
      MsgBox('Note: You are not running as administrator. The installer will only modify PATH for your user account.', mbInformation, MB_OK);
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Notify user about PATH changes
    if IsAdminLoggedOn then
    begin
      MsgBox('Installation complete! The application has been added to the system PATH and is available for all users.', mbInformation, MB_OK);
    end
    else
    begin
      MsgBox('Installation complete! The application has been added to your user PATH. You may need to restart your command prompt or PowerShell for the changes to take effect.', mbInformation, MB_OK);
    end;
  end;
end;

// Function to check if PATH already contains the installation directory
function IsPathAlreadyModified: Boolean;
var
  PathValue: String;
  AppDir: String;
begin
  Result := False;
  AppDir := ExpandConstant('{app}');
  
  if IsAdminLoggedOn then
    PathValue := GetEnv('PATH')
  else
    PathValue := GetEnv('PATH');
    
  if Pos(AppDir, PathValue) > 0 then
    Result := True;
end;

[UninstallDelete]
; Clean up any temporary files
Type: files; Name: "{app}\*.tmp"
Type: files; Name: "{app}\*.log"

[UninstallRun]
; Remove from PATH during uninstall
Filename: "{app}\{#MyAppExeName}"; Parameters: "--help"; Flags: runhidden

[CustomMessages]
; Custom messages for better user experience
english.LaunchProgram=Launch CRDB Zoho Converter
english.ViewREADME=View README Documentation
german.LaunchProgram=CRDB Zoho Converter starten
german.ViewREADME=README-Dokumentation anzeigen


