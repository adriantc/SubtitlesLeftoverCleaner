{ Subtitles Leftover Cleaner
Copyleft 2016 Adrian-Costin Tundrea

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.fsf.org/licensing/licenses/>. }

program SubtitlesLeftoverCleaner;

{$APPTYPE CONSOLE}
{$R *.res}

{$R 'VersionInfo.res' 'VersionInfo.rc'}

uses
  System.SysUtils,
  StrUtils,
  IOUtils;

function CleanDirectory(const Name: string): Boolean;
var
  SearchResult: TSearchRec;
  SubtitlesOnlyFolder: Boolean;
  EmptyFolder: Boolean;
  Filepath: String;
begin
  SubtitlesOnlyFolder := true;
  EmptyFolder := true;

  Writeln('Cleaning up folder ' + Name + '\' + SearchResult.Name);
  if FindFirst(Name + '\*', faAnyFile, SearchResult) = 0 then begin
    try
      repeat
        Writeln('Analyzing path ' + Name + '\' + SearchResult.Name);
        if (SearchResult.Attr and faDirectory <> 0) then begin
          if (SearchResult.Name <> '.') and (SearchResult.Name <> '..') then begin
            Writeln('Folder found! (' + Name + '\' + SearchResult.Name);
            EmptyFolder := CleanDirectory(Name + '\' + SearchResult.Name);
            SubtitlesOnlyFolder := EmptyFolder;
          end;
        end else begin
          EmptyFolder := false;
          Writeln('File found! (' + Name + '\' + SearchResult.Name);
          if (not AnsiContainsStr(SearchResult.Name, '.ro.srt')) then begin
            SubtitlesOnlyFolder := false;
            Writeln('A file that is not a subtitle has been found! Skipping...');
            Continue;
          end;
        end;
      until FindNext(SearchResult) <> 0;

      if (EmptyFolder or SubtitlesOnlyFolder) then begin
        if (SubtitlesOnlyFolder) then begin
          { Cleaning up its content first, otherwise RemoveDir will fail! }
          Writeln('Folder ' + Name + ' only had subtitle file(s). Removing its content!');
          for Filepath in TDirectory.GetFiles(Name, '*.*', TSearchOption.soAllDirectories) do begin
            TFile.Delete(Filepath);
          end;
        end;
        Writeln('Removing folder ' + Name + '!');
        RemoveDir(Name);
        Result := true;
      end else begin
        Result := false;
      end;
    finally
      FindClose(SearchResult);
    end;
  end else begin
    Result := true;
  end;
end;

begin
  try
    Writeln('Subtitle Leftover Cleaner');
    Writeln('v1.0.0 (Build 1) - 16.01.2016');
    Writeln('Adrian-Costin Tundrea');
    Writeln;
    if (ParamCount = 1) then begin
      CleanDirectory(paramstr(1));
    end else begin
      Writeln('Error: Application must be called with a single parameter that represents the folder path to clean!');
      Writeln('Press any key to exit...');
      Readln;
    end;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;

end.
