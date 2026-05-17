; =============================================================================
; Almazin App — Windows Installer Script
; =============================================================================
; Build tool: Inno Setup 6.x
; Output: Almazin-Setup-{version}.exe
;
; Features:
;   - Installs to %LOCALAPPDATA%\Almazin
;   - Start Menu entry
;   - Optional Desktop shortcut
;   - Uninstall support
;   - Preserves user data (Hive stores in %APPDATA%, outside install dir)
;   - Upgrade-safe (detects existing installation)
;   - Branded with official app icon
; =============================================================================

#define MyAppName "بن المازن"
#define MyAppExeName "almazin_app.exe"
#define MyAppPublisher "Almazin"
#define MyAppURL "https://github.com/almazin"
#define MyAppIcon "app_icon.ico"

; Version is passed from CI via command line:
;   /DMyAppVersion=nightly-20260517-1259 (for release name)
;   /DMyAppVersionNumeric=1.0.0.202605171259 (for Windows version info)
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#ifndef MyAppVersionNumeric
  #define MyAppVersionNumeric "1.0.0.0"
#endif

[Setup]
; ── App Identity ─────────────────────────────────────────────────────────────
AppId={{A7B3C9D1-E2F4-5A6B-8C9D-0E1F2A3B4C5D}
AppName={#MyAppName}
AppVersion={#MyAppVersionNumeric}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion={#MyAppVersionNumeric}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=Almazin App — Coffee Blend Management
VersionInfoProductName=Almazin App
VersionInfoProductVersion={#MyAppVersionNumeric}

; ── Installation ─────────────────────────────────────────────────────────────
DefaultDirName={localappdata}\Almazin
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=output
OutputBaseFilename=Almazin-Setup-{#MyAppVersion}
SetupIconFile={#MyAppIcon}
UninstallDisplayIcon={app}\{#MyAppExeName}

; ── Compression ──────────────────────────────────────────────────────────────
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=100,100

; ── UI ───────────────────────────────────────────────────────────────────────
WizardSmallImageFile=
DisableWelcomePage=no
LicenseFile=
InfoBeforeFile=

; ── Architecture ─────────────────────────────────────────────────────────────
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; ── Application Files ────────────────────────────────────────────────────────
Source: "Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; ── Start Menu ───────────────────────────────────────────────────────────────
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

; ── Desktop ──────────────────────────────────────────────────────────────────
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; ── Launch after install ─────────────────────────────────────────────────────
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; ── Clean up on uninstall (but NOT user data) ────────────────────────────────
; Hive data is stored in %APPDATA%, NOT in the install directory.
; This ensures user data is preserved during uninstall/reinstall.
; The following only removes the installation directory contents.
Type: filesandordirs; Name: "{app}"

[Registry]
; ── File Association (future: .almazin backup files) ─────────────────────────
; Reserved for future use when backup file associations are added.
