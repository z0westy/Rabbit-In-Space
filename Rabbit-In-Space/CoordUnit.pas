unit CoordUnit;

interface

uses
  Vcl.ExtCtrls, TypesUnit;

function AngleToCoord(Angle: Byte): TByteArray;
function GetLeftUpAngle(X, Y: Byte): TWordArray;
procedure PutToRightAngle(TemplImage: TImage; Angle: Byte);
procedure SetStartPlayerPos(Angle: Byte);

implementation

uses
  GameUnit;

function AngleToCoord(Angle: Byte): TByteArray;
begin
  case Angle of
    1: Result := [High(MyFloor.Map[1]), Low(MyFloor.Map)];
    2: Result := [High(MyFloor.Map[1]), High(MyFloor.Map)];
    3: Result := [Low(MyFloor.Map[1]), High(MyFloor.Map)];
    4: Result := [Low(MyFloor.Map[1]), Low(MyFloor.Map)];
  end;
end;

function GetLeftUpAngle(X, Y: Byte): TWordArray;
begin
  Result := [GameForm.FieldImage.Left + 96 * (X - 1), GameForm.FieldImage.Top + 96 * (Y - 1)];
end;

procedure PutToRightAngle(TemplImage: TImage; Angle: Byte);
var
  Coord: TByteArray;
  Buf: TWordArray;
begin
  Coord := AngleToCoord(Angle);
  Buf := GetLeftUpAngle(Coord[0], Coord[1]);

  TemplImage.Left := Buf[0] + 12;
  TemplImage.Top := Buf[1] + 12;
end;

procedure SetStartPlayerPos(Angle: Byte);
var
  Coord: TByteArray;
  Buf: TWordArray;
begin
  Coord := AngleToCoord(Angle);

  MyFloor.MyPlayer.X := Coord[0];
  MyFloor.MyPlayer.Y := Coord[1];

  Buf := GetLeftUpAngle(MyFloor.MyPlayer.X, MyFloor.MyPlayer.Y);

  GameForm.PlayerImage.Left := Buf[0] + 12;
  GameForm.PlayerImage.Top := Buf[1] + 12;
end;

end.
