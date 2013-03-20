
#define AppVersion '4.4'
#define AppName    'Scid'
#define TCLDIR     'C:\Tcl'
#define OptionalSoftware 'StockFish'
#define OptionalSoftwareURL 'http://stockfishchess.org/'

[Setup]
AppName={# AppName}
AppVerName={# AppName} {# AppVersion}
AppVersion={# AppVersion}
AppPublisher=The Scid project
AppPublisherURL=http://http://scid.sourceforge.net
DefaultDirName={userdocs}\{# AppName}-{# AppVersion}
DefaultGroupName={# AppName}
DisableStartupPrompt=yes
WindowShowCaption=yes
WindowVisible=no
AllowNoIcons=yes
LicenseFile=COPYING
Compression=bzip/9
SourceDir=.
OutputDir=.
OutputBaseFilename={# AppName}-{# AppVersion}
ChangesAssociations=yes
PrivilegesRequired=lowest

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"
Name: "associate_pgn"; Description: "&Associate PGN files"; GroupDescription: "Other tasks:"
Name: "associate_si4"; Description: "&Associate SI4 files"; GroupDescription: "Other tasks:"

[Registry]
Root: "HKCU"; Subkey: "Software\Classes\.pgn"; Flags: uninsdeletevalue; Tasks: associate_pgn
Root: "HKCU"; Subkey: "Software\Classes\.pgn"; ValueType: string; ValueData: "scid"; Flags: uninsdeletevalue; Tasks: associate_pgn
Root: "HKCU"; Subkey: "Software\Classes\scid"; Flags: uninsdeletevalue; Tasks: associate_pgn
Root: "HKCU"; Subkey: "Software\Classes\scid\shell\open\command"; ValueType: string; ValueData: """{app}\bin\scid"" ""%1"""; Flags: uninsdeletevalue; Tasks: associate_pgn

Root: "HKCU"; Subkey: "Software\Classes\.si4"; Flags: uninsdeletevalue; Tasks: associate_si4
Root: "HKCU"; Subkey: "Software\Classes\.si4"; ValueType: string; ValueData: "scid"; Flags: uninsdeletevalue; Tasks: associate_si4
Root: "HKCU"; Subkey: "Software\Classes\scid"; Flags: uninsdeletevalue; Tasks: associate_si4
Root: "HKCU"; Subkey: "Software\Classes\scid\shell\open\command"; ValueType: string; ValueData: """{app}\bin\scid"" ""%1"""; Flags: uninsdeletevalue; Tasks: associate_si4


[Files]
Source: "Release\*";  DestDir: "{app}\bin"; CopyMode: normal;
Source: "scid.eco";  DestDir: "{app}\bin"; CopyMode: normal;
Source: "books\*";  DestDir: "{app}\bin\books"; CopyMode: normal; Flags: recursesubdirs
Source: "engines\*";  DestDir: "{app}\bin\engines"; CopyMode: normal; Flags: recursesubdirs
Source: "html\*";  DestDir: "{app}\bin\html"; CopyMode: normal; Flags: recursesubdirs
Source: "sounds\*";  DestDir: "{app}\bin\sounds"; CopyMode: normal; Flags: recursesubdirs
Source: "bitmaps\*";  DestDir: "{app}\bitmaps"; CopyMode: normal; Flags: recursesubdirs
Source: "bitmaps2\*";  DestDir: "{app}\bitmaps2"; CopyMode: normal; Flags: recursesubdirs
Source: "help\*"; DestDir: "{app}\help";  CopyMode: normal; Flags: recursesubdirs
Source: "COPYING"; DestDir: "{app}";  CopyMode: normal;
Source: "README"; DestDir: "{app}";  CopyMode: normal;
Source: "THANKS"; DestDir: "{app}";  CopyMode: normal;
Source: "CHANGES"; DestDir: "{app}";  CopyMode: normal;
Source: "{# TCLDIR}\bin\tcl85.dll"; DestDir: "{app}\bin";  CopyMode: normal;
Source: "{# TCLDIR}\bin\tk85.dll"; DestDir: "{app}\bin";  CopyMode: normal;
Source: "{# TCLDIR}\lib\tcl8\*"; DestDir: "{app}\lib\tcl8";  CopyMode: normal; Flags: recursesubdirs
Source: "{# TCLDIR}\lib\tcl8.5\*"; DestDir: "{app}\lib\tcl8.5";  CopyMode: normal; Flags: recursesubdirs
Source: "{# TCLDIR}\lib\tk8.5\*"; DestDir: "{app}\lib\tk8.5";  CopyMode: normal; Flags: recursesubdirs
Source: "{# TCLDIR}\lib\teapot\package\win32-ix86\lib\*"; DestDir: "{app}\lib";  CopyMode: normal; Flags: recursesubdirs



[Icons]
Name: "{group}\{# AppName}"; Filename: "{app}\bin\scid.exe"; Comment: "{# AppName}!"; WorkingDir: {app}\bin
Name: "{group}\Uninstall {# AppName}"; Filename: "{uninstallexe}";
Name: "{userdesktop}\{# AppName}"; Filename: "{app}\bin\scid.exe"; Tasks: desktopicon; Comment: "Desktop {# AppName}!"; WorkingDir: {app}\bin


[Run]
Filename: "{app}\bin\scid.exe"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent


[Code]

procedure URLLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', '{# OptionalSoftwareUrl}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure CreateTheWizardPage;
var
  Page: TWizardPage;
  Line1, Line2: TNewStaticText;
     URLLabel: TNewStaticText;
     
begin

  Page := CreateCustomPage(wpSelectComponents, '{# OptionalSoftware}', '{# OptionalSoftware}');


  Line1 := TNewStaticText.Create(Page);
  Line1.Top :=  ScaleY(8);
  Line1.Caption := 'Optionally, {# OptionalSoftware} may also be installed.';
  
  Line1.AutoSize := True;
  Line1.Parent := Page.Surface;
  
    Line2 := TNewStaticText.Create(Page);
  Line2.Top :=  Line1.Top + Line1.Height + ScaleY(8);
  Line2.Caption := 'You can get it free from ';
  Line2.AutoSize := True;
  Line2.Parent := Page.Surface;

  URLLabel := TNewStaticText.Create(Page);
  URLLabel.Caption := '{# OptionalSoftwareUrl}';
  URLLabel.Cursor := crHand;
  URLLabel.OnClick := @URLLabelOnClick;
  URLLabel.Parent := Page.Surface;
  
  URLLabel.Font.Style := URLLabel.Font.Style + [fsUnderline];
  URLLabel.Font.Color := clBlue;
  URLLabel.Top := Line2.Top;
  URLLabel.Left := Line2.Left + Line2.Width + ScaleX(1);

end;



var
  tclPage: TOutputMsgWizardPage;

procedure InitializeWizard();
begin
CreateTheWizardPage;

end;

