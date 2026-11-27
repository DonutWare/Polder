#define SourcePath ".."

#ifndef POLDER_VERSION
  #define POLDER_VERSION "latest"
#endif

[Setup]
AppId={{DF89E60C-4FE4-433D-86DB-F9FA4CB5F54D}
AppName="Polder Calendar"
AppVersion={#POLDER_VERSION}
AppPublisher="DonutWare"
AppPublisherURL="https://github.com/DonutWare/Polder"
AppSupportURL="https://github.com/DonutWare/Polder"
AppUpdatesURL="https://github.com/DonutWare/Polder"
DefaultDirName={localappdata}\Programs\Polder Calendar
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename=polder_calendar_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
CloseApplications=force
RestartApplications=no

SetupLogging=yes
UninstallLogging=yes
UninstallDisplayName="Polder Calendar"
UninstallDisplayIcon={app}\polder_calendar.exe
SetupIconFile="{#SourcePath}\windows\runner\resources\app_icon.ico"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourcePath}\build\windows\x64\prod\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Polder Calendar"; Filename: "{app}\polder_calendar.exe"
Name: "{autodesktop}\Polder Calendar"; Filename: "{app}\polder_calendar.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\polder_calendar.exe"; Description: "{cm:LaunchProgram,Polder Calendar}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if MsgBox('Would you like to delete the application''s data? This action cannot be undone.', mbConfirmation, MB_YESNO) = IDYES then
        begin
            if DelTree(ExpandConstant('{userappdata}\org.knaapen\Polder Calendar'), True, True, True) = False then
            begin
                Log(ExpandConstant('{userappdata}\org.knaapen\Polder Calendar could not be deleted. Skipping...'));
            end;
        end;
      end;
  end;
end;
