unit RandGenUnit;

interface

uses
  TypesUnit;

function CheckOnNewFloor: Boolean;
procedure InitFloorRooms;
procedure GetRandFloorColour(var TakenColours: Array of Boolean);
procedure GetRandLiftAngle;
procedure GetRandLadderAngle(IsFirstGen: Boolean);
procedure GetRandMainRoomAngle;
procedure GetSecondRoomAngle;
procedure GenerateNewPlut;
procedure GenFloorComponents(var TakenColours: Array of Boolean; var LiftAngle: Byte;
                             IsFirstFloor: Boolean);

implementation

uses
  GameUnit, CoordUnit, WallsUnit, LabirintUnit;

function CheckOnNewFloor: Boolean;
var
  Buf: TByteArray;
begin
  if IsLiftUsed then
    Buf := AngleToCoord(MyFloor.LadderAngle)
  else
    Buf := AngleToCoord(MyFloor.LiftAngle);
  if (MyFloor.MyPlayer.X = Buf[0]) and (MyFloor.MyPlayer.Y = Buf[1]) then
    Result := True
  else Result := False;
end;

procedure InitFloorRooms;
begin
  MyFloor.MainRoom.SizeX := Random(3) + 3;
  MyFloor.MainRoom.SizeY := Random(3) + 3;
  MyFloor.MainRoom.Value := 1;

  MyFloor.SecondRoom.SizeX := Random(2) + 3;
  MyFloor.SecondRoom.SizeY := Random(2) + 3;
  MyFloor.SecondRoom.Value := 2;
end;

procedure GetRandFloorColour(var TakenColours: Array of Boolean);
begin
  repeat
    MyFloor.ColourIndex := Random(7);
  until not (TakenColours[MyFloor.ColourIndex]);
  TakenColours[MyFloor.ColourIndex] := True;
end;

procedure GetRandLiftAngle;
begin
  MyFloor.LiftAngle := Random(4) + 1;
  PutToRightAngle(GameForm.LiftImage, MyFloor.LiftAngle);
  MyFloor.TakenAngles[MyFloor.LiftAngle] := True;
end;

procedure GetRandLadderAngle(IsFirstGen: Boolean);
begin
  repeat
    MyFloor.LadderAngle := Random(4) + 1;
  until not (MyFloor.TakenAngles[MyFloor.LadderAngle] or (CheckOnNewFloor));

  PutToRightAngle(GameForm.LadderImage, MyFloor.LadderAngle);
  MyFloor.TakenAngles[MyFloor.LadderAngle] := True;
end;

procedure GetRandMainRoomAngle;
begin
  repeat
   MyFloor.MainRoom.Angle := Random(4) + 1;
  until not (MyFloor.TakenAngles[MyFloor.MainRoom.Angle]);
  MyFloor.TakenAngles[MyFloor.MainRoom.Angle] := True;
end;

procedure GetSecondRoomAngle;
begin
  MyFloor.SecondRoom.Angle := 1;
  while MyFloor.TakenAngles[MyFloor.SecondRoom.Angle] do
    Inc(MyFloor.SecondRoom.Angle);
  MyFloor.TakenAngles[MyFloor.SecondRoom.Angle] := True;
end;

procedure GenerateNewPlut;
var
  Buf: TWordArray;
begin
  repeat
    MyFloor.Plut.X := Random(High(MyFloor.Map[1])-1) + 1;
    MyFloor.Plut.Y := Random(High(MyFloor.Map)-1) + 1;
  until (MyFloor.Plut.X <= High(MyFloor.Map[1]) - 2) and
        (MyFloor.Plut.X >= Low(MyFloor.Map[1]) + 2) and
        (MyFloor.Plut.Y <= High(MyFloor.Map) - 2) and
        (MyFloor.Plut.Y >= Low(MyFloor.Map) + 2) and
        (Abs(MyFloor.MyPlayer.X - MyFloor.Plut.X) >= 2) and
        (Abs(MyFloor.MyPlayer.Y - MyFloor.Plut.Y) >= 2) and
        (MyFloor.Map[MyFloor.Plut.Y, MyFloor.Plut.X] = 0);

  Buf := GetLeftUpAngle(MyFloor.Plut.X, MyFloor.Plut.Y);
  GameForm.PlutImage.Left := Buf[0] + 16;
  GameForm.PlutImage.Top := Buf[1] + 16;
  GameForm.PlutImage.Visible := True;
end;

procedure GenFloorComponents(var TakenColours: Array of Boolean; var LiftAngle: Byte;
                             IsFirstFloor: Boolean);
var
  I: Integer;
begin
  if IsFirstFloor then
    for I := Low(TakenColours) to High(TakenColours) do
      TakenColours[I] := False;
  GetRandFloorColour(TakenColours);
  GameForm.FieldImagesVirtList.GetIcon(MyFloor.ColourIndex, GameForm.FieldImage.Picture.Icon);

  if IsFirstFloor then
  begin
    GetRandLiftAngle;
    LiftAngle := MyFloor.LiftAngle;
  end
  else
  begin
    MyFloor.TakenAngles[LiftAngle] := True;
    MyFloor.LiftAngle := LiftAngle;
  end;

  GetRandLadderAngle(IsFirstFloor);

  InitFloorRooms;

  GetRandMainRoomAngle;
  GetSecondRoomAngle;

  WallsGenerate(MyFloor.MainRoom);
  WallsGenerate(MyFloor.SecondRoom);

  for I := Low(TileImagesArray) to High(TileImagesArray) do
    TileImagesArray[I].Visible := False;
  SetLength(TileImagesArray, 0);

  ShowWalls(MyFloor.MainRoom);
  ShowWalls(MyFloor.SecondRoom);

  if IsFirstFloor then
    SetStartPlayerPos(MyFloor.MainRoom.Angle);

  GenerateNewPlut;
  MyFloor.Path := GetLabirintPath(MyFloor.Map, MyFloor.MyPlayer.X, MyFloor.MyPlayer.Y,
                                  MyFloor.Plut.X, MyFloor.Plut.Y);
end;

end.
