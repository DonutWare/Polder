#define SourcePath ".."

#ifndef POLDER_VERSION
  #define POLDER_VERSION "latest"
#endif

[Setup]
AppId={{0FF01413-3560-4A16-9BB7-851B893E1279}
AppName="Polder Notes"
AppVersion={#POLDER_VERSION}
AppPublisher="DonutWare"
AppPublisherURL="https://github.com/DonutWare/Polder"
AppSupportURL="https://github.com/DonutWare/Polder"
AppUpdatesURL="https://github.com/DonutWare/Polder"
DefaultDirName={localappdata}\Programs\Polder Notes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename=polder_notes_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
CloseApplications=force
RestartApplications=no

SetupLogging=yes
UninstallLogging=yes
UninstallDisplayName="Polder Notes"
UninstallDisplayIcon={app}\polder_notes.exe
SetupIconFile="{#SourcePath}\windows\runner\resources\app_icon.ico"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourcePath}\build\windows\x64\prod\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Polder Notes"; Filename: "{app}\polder_notes.exe"
Name: "{autodesktop}\Polder Notes"; Filename: "{app}\polder_notes.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\polder_notes.exe"; Description: "{cm:LaunchProgram,Polder Notes}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if MsgBox('Would you like to delete the application''s data? This action cannot be undone.', mbConfirmation, MB_YESNO) = IDYES then
        begin
            if DelTree(ExpandConstant('{userappdata}\org.knaapen\Polder Notes'), True, True, True) = False then
            begin
                Log(ExpandConstant('{userappdata}\org.knaapen\Polder Notes could not be deleted. Skipping...'));
            end;
        end;
      end;
  end;
end;
