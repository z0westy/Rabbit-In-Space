unit DirectionUnit;

interface

uses
  TypesUnit;

function ConvertDirToNum(Dir: TDir): Byte;
procedure DirectionOutput;

implementation

uses
  GameUnit;

function ConvertDirToNum(Dir: TDir): Byte;
begin
  case Dir of
    DirDown: Result := 0;
    DirUp: Result := 4;
    DirLeft: Result := 8;
    DirRight: Result := 12;
  end;
end;

procedure DirectionOutput;
begin
  case MyFloor.Path[MyFloor.Steps] of
    DirUp:
    begin
      GameForm.DirLabel.Caption := '¬верх';
      GameForm.DirImagesList.GetIcon(3, GameForm.DirImage.Picture.Icon);
    end;
    DirRight:
    begin
      GameForm.DirLabel.Caption := '¬право';
      GameForm.DirImagesList.GetIcon(2, GameForm.DirImage.Picture.Icon);
    end;
    DirDown:
    begin
      GameForm.DirLabel.Caption := '¬низ';
      GameForm.DirImagesList.GetIcon(1, GameForm.DirImage.Picture.Icon);
    end;
    DirLeft:
    begin
      GameForm.DirLabel.Caption := '¬лево';
      GameForm.DirImagesList.GetIcon(0, GameForm.DirImage.Picture.Icon);
    end;
  end;
end;

end.
