#define SourcePath ".."

#ifndef POLDER_VERSION
  #define POLDER_VERSION "latest"
#endif

[Setup]
AppId={{DF42E382-DE33-445D-A3C7-FD714991E9B6}
AppName="Polder"
AppVersion={#POLDER_VERSION}
AppPublisher="DonutWare"
AppPublisherURL="https://github.com/DonutWare/Polder"
AppSupportURL="https://github.com/DonutWare/Polder"
AppUpdatesURL="https://github.com/DonutWare/Polder"
DefaultDirName={localappdata}\Programs\Polder
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename=polder_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

SetupLogging=yes
UninstallLogging=yes
UninstallDisplayName="Polder"
UninstallDisplayIcon={app}\polder.exe
SetupIconFile="{#SourcePath}\windows\runner\resources\app_icon.ico"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourcePath}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Polder"; Filename: "{app}\polder.exe"
Name: "{autodesktop}\Polder"; Filename: "{app}\polder.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\polder.exe"; Description: "{cm:LaunchProgram,Polder}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if MsgBox('Would you like to delete the application''s data? This action cannot be undone.', mbConfirmation, MB_YESNO) = IDYES then
        begin
            if DelTree(ExpandConstant('{userappdata}\org.knaapen\Polder'), True, True, True) = False then
            begin
                Log(ExpandConstant('{userappdata}\org.knaapen\Polder could not be deleted. Skipping...'));
            end;
        end;
      end;
  end;
end;
