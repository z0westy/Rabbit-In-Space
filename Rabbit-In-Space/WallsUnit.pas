unit WallsUnit;

interface

uses
  Vcl.ExtCtrls, TypesUnit, CoordUnit;

function CheckExitValid(RandExit, X, Y: Byte): Boolean;
procedure WallsGenerate(Room: TRoom);
procedure ShowWalls(Room: TRoom);

implementation

uses
  GameUnit;

function CheckExitValid(RandExit, X, Y: Byte): Boolean;
begin
  if (RandExit = 1) or (RandExit = X + Y - 1) or (RandExit = X) or (RandExit = Y) then
    Result := False
  else Result := True;
end;

procedure WallsGenerate(Room: TRoom);
var
  X, Y: Byte;
begin
  case Room.Angle of
    1:
    begin
      for X := Length(MyFloor.Map[1]) - Room.SizeX + 1 to Length(MyFloor.Map[1]) do
        MyFloor.Map[Room.SizeY, X] := Room.Value;
      for Y := 1 to Room.SizeY do
        MyFloor.Map[Y, Length(MyFloor.Map[1]) - Room.SizeX + 1] := Room.Value;
    end;
    2:
    begin
      for X := Length(MyFloor.Map[1]) - Room.SizeX + 1 to Length(MyFloor.Map[1]) do
        MyFloor.Map[Length(MyFloor.Map) - Room.SizeY + 1, X] := Room.Value;
      for Y := Length(MyFloor.Map) - Room.SizeY + 1 to Length(MyFloor.Map) do
        MyFloor.Map[Y, Length(MyFloor.Map[1]) - Room.SizeX + 1] := Room.Value;
    end;
    3:
    begin
      for X := 1 to Room.SizeX do
        MyFloor.Map[Length(MyFloor.Map) - Room.SizeY + 1, X] := Room.Value;
      for Y := Length(MyFloor.Map) - Room.SizeY + 1 to Length(MyFloor.Map) do
        MyFloor.Map[Y, Room.SizeX] := Room.Value;
    end;
    4:
    begin
      for X := 1 to Room.SizeX do
        MyFloor.Map[Room.SizeY, X] := Room.Value;
      for Y := 1 to Room.SizeY do
        MyFloor.Map[Y, Room.SizeX] := Room.Value;
    end;
  end;
end;

procedure ShowWalls(Room: TRoom);
var
  Buf: TWordArray;
  BufImage: TImage;
  IsRandFound: Boolean;
  RandExit, X, Y: Byte;
begin
  IsRandFound := False;

  repeat
    RandExit := Random(Room.SizeX + Room.SizeY - 1) + 1;
  until CheckExitValid(RandExit, Room.SizeX, Room.SizeY);

  For Y := Low(MyFloor.Map) to High(MyFloor.Map) do
    For X := Low(MyFloor.Map[1]) to High(MyFloor.Map[1]) do
      If MyFloor.Map[Y, X] = Room.Value then
      begin
        if (Room.Tiles <> RandExit - 1) or IsRandFound then
        begin
          BufImage := TImage.Create(GameForm);
          TileImagesArray := TileImagesArray + [BufImage];

          GameForm.TileImagesList.GetIcon(0, TileImagesArray[MyFloor.NumTiles].Picture.Icon);
          TileImagesArray[MyFloor.NumTiles].Parent := GameForm;
          Buf := GetLeftUpAngle(X, Y);
          TileImagesArray[MyFloor.NumTiles].Left := Buf[0];
          TileImagesArray[MyFloor.NumTiles].Top := Buf[1];

          Inc(MyFloor.NumTiles);
          Inc(Room.Tiles);
        end
        else
        begin
          MyFloor.Map[Y, X] := 0;
          IsRandFound := True;
        end;
      end;
end;

end.
