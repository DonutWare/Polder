#define SourcePath ".."

#ifndef POLDER_VERSION
  #define POLDER_VERSION "latest"
#endif

[Setup]
AppId={{9F15FA5D-B87E-4D20-B0AF-C5D65596FC01}
AppName="Polder Drive"
AppVersion={#POLDER_VERSION}
AppPublisher="DonutWare"
AppPublisherURL="https://github.com/DonutWare/Polder"
AppSupportURL="https://github.com/DonutWare/Polder"
AppUpdatesURL="https://github.com/DonutWare/Polder"
DefaultDirName={localappdata}\Programs\Polder Drive
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename=polder_drive_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
CloseApplications=force
RestartApplications=no

SetupLogging=yes
UninstallLogging=yes
UninstallDisplayName="Polder Drive"
UninstallDisplayIcon={app}\polder_drive.exe
SetupIconFile="{#SourcePath}\windows\runner\resources\app_icon.ico"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourcePath}\build\windows\x64\prod\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Polder Drive"; Filename: "{app}\polder_drive.exe"
Name: "{autodesktop}\Polder Drive"; Filename: "{app}\polder_drive.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\polder_drive.exe"; Description: "{cm:LaunchProgram,Polder Drive}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if MsgBox('Would you like to delete the application''s data? This action cannot be undone.', mbConfirmation, MB_YESNO) = IDYES then
        begin
            if DelTree(ExpandConstant('{userappdata}\org.knaapen\Polder Drive'), True, True, True) = False then
            begin
                Log(ExpandConstant('{userappdata}\org.knaapen\Polder Drive could not be deleted. Skipping...'));
            end;
        end;
      end;
  end;
end;
