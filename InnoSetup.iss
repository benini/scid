
#define AppVersion '4.5.1'
#define AppName    'Scid'
#define TCLDIR     'C:\Tcl'

[Setup]
AppName={# AppName}
AppVerName={# AppName} {# AppVersion}
AppVersion={# AppVersion}
AppPublisher=The Scid project
AppPublisherURL=http://http://scid.sourceforge.net
UsePreviousAppDir=no
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
Name: "install_stockfish"; Description: "&Stockfish ( http://stockfishchess.org )"; GroupDescription: "Chess engines:"

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
Source: "Release\*"; DestDir: "{app}\bin"
Source: "scid.eco"; DestDir: "{app}\bin"
Source: "img\*"; DestDir: "{app}\bin\img"; Flags: recursesubdirs
Source: "books\*"; DestDir: "{app}\bin\books"; Flags: recursesubdirs
Source: "stockfish.exe"; DestDir: "{app}\bin\engines"; Tasks: install_stockfish
Source: "html\*"; DestDir: "{app}\bin\html"; Flags: recursesubdirs
Source: "sounds\*"; DestDir: "{app}\bin\sounds"; Flags: recursesubdirs
Source: "bitmaps\*"; DestDir: "{app}\bitmaps"; Flags: recursesubdirs
Source: "bitmaps2\*"; DestDir: "{app}\bitmaps2"; Flags: recursesubdirs
Source: "help\*"; DestDir: "{app}\help"; Flags: recursesubdirs
Source: "COPYING"; DestDir: "{app}"
Source: "README"; DestDir: "{app}"
Source: "THANKS"; DestDir: "{app}"
Source: "CHANGES"; DestDir: "{app}"
Source: "{# TCLDIR}\bin\tcl85.dll"; DestDir: "{app}\bin"
Source: "{# TCLDIR}\bin\tk85.dll"; DestDir: "{app}\bin"
Source: "{# TCLDIR}\lib\tcl8\*"; DestDir: "{app}\lib\tcl8"; Flags: recursesubdirs
Source: "{# TCLDIR}\lib\tcl8.5\*"; DestDir: "{app}\lib\tcl8.5"; Flags: recursesubdirs
Source: "{# TCLDIR}\lib\tk8.5\*"; DestDir: "{app}\lib\tk8.5"; Flags: recursesubdirs
Source: "{# TCLDIR}\lib\teapot\package\win32-ix86\lib\*"; DestDir: "{app}\lib"; Flags: recursesubdirs skipifsourcedoesntexist
Source: "{# TCLDIR}\lib\teapot\package\win32-x86_64\lib\*"; DestDir: "{app}\lib"; Flags: recursesubdirs skipifsourcedoesntexist

[Dirs]
Name: "{app}\bin\config"

[Icons]
Name: "{group}\{# AppName}"; Filename: "{app}\bin\scid.exe"; Comment: "{# AppName}!"; WorkingDir: {app}\bin
Name: "{group}\Uninstall {# AppName}"; Filename: "{uninstallexe}";
Name: "{userdesktop}\{# AppName}"; Filename: "{app}\bin\scid.exe"; Tasks: desktopicon; Comment: "Desktop {# AppName}!"; WorkingDir: {app}\bin

[Run]
Filename: "{app}\bin\scid.exe"; Flags: nowait postinstall skipifsilent; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"

[Messages]
FinishedLabelNoIcons=Setup has finished installing [name] on your computer. Visit our wiki pages ( http://sourceforge.net/p/scid/wiki ) to get additional resources.

[Code]
procedure CreateEngineDat();
var
  fileName : string;
  lines : TArrayOfString;
  Index: Integer;
begin
  fileName := ExpandConstant('{app}\bin\config\engines.dat');

  Index := 6
  if Index <> -1 then
  begin
      if WizardForm.TasksList.Checked[Index] then
      begin
          SetArrayLength(lines, 13);
          lines[0]  := '# Analysis engines list file for Scid'
          lines[1]  := ''
          lines[2]  := 'engine {'
          lines[3]  := '  Name Stockfish'
          lines[4]  := '  Cmd  ../engines/stockfish.exe'
          lines[5]  := '  Args {}'
          lines[6]  := '  Dir  .'
          lines[7]  := '  Elo  0'
          lines[8]  := '  Time 0'
          lines[9]  := '  URL  {}'
          lines[10] := '  UCI 1'
          lines[11] := '  UCIoptions {{MultiPV 3}}'
          lines[12] := '}'
          SaveStringsToFile(filename,lines,true);
      end
  end
end;
 
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if  CurStep=ssDone then
    begin
         CreateEngineDat();
    end
end;