unit LabirintUnit;

interface

uses
  TypesUnit;

function GetLabirintPath(MainMap: TMapArray; StartX: Byte; StartY: Byte; FindX: Byte;
                        FindY: Byte): TPath;

implementation

function GetLabirintPath(MainMap: TMapArray; StartX: Byte; StartY: Byte; FindX: Byte; FindY: Byte): TPath;
var
  Map: TMapArray;
  coords1, coords2: TByte2Array;
  I, J: ShortInt;
  IsPathFinded: Boolean;
begin
  Result := [];

  if (StartX = FindX) and (StartY = FindY) then
    IsPathFinded := True
  else IsPathFinded := False;

  Map := MainMap;

  Map[FindY, FindX] := 0;

  coords1 := [[StartY, StartX]];

  while (Length(coords1) > 0) and not (IsPathFinded) do
  begin
    I := 0;
    while I <= Length(coords1) - 1 do
    begin
      if (coords1[I, 1] > Low(Map[1])) and (Map[coords1[I, 0], coords1[I, 1] - 1] = 0) then
        if (coords1[I, 0] = FindY) and (coords1[I, 1] - 1 = FindX) then
        begin
          IsPathFinded := True;
          Result := GetLabirintPath(MainMap, StartX, StartY, coords1[I, 1], coords1[I, 0]) + [DirLeft];
          Break;
        end
        else
        begin
          Map[coords1[I, 0], coords1[I, 1] - 1] := 1;
          coords2 := coords2 + [[coords1[I, 0], coords1[I, 1] - 1]];
        end;

      if (coords1[I, 1] < High(Map[1])) and (Map[coords1[I, 0], coords1[I, 1] + 1] = 0) then
        if (coords1[I, 0] = FindY) and (coords1[I, 1] + 1 = FindX) then
        begin
          IsPathFinded := True;
          Result := GetLabirintPath(MainMap, StartX, StartY, coords1[I, 1], coords1[I, 0]) + [DirRight];
          Break;
        end
        else
        begin
          Map[coords1[I, 0], coords1[I, 1] + 1] := 1;
          coords2 := coords2 + [[coords1[I, 0], coords1[I, 1] + 1]];
        end;

      if (coords1[I, 0] > Low(Map)) and (Map[coords1[I, 0] - 1, coords1[I, 1]] = 0) then
        if (coords1[I, 0] - 1 = FindY) and (coords1[I, 1] = FindX) then
        begin
          IsPathFinded := True;
          Result := GetLabirintPath(MainMap, StartX, StartY, coords1[I, 1], coords1[I, 0]) + [DirUp];
          Break;
        end
        else
        begin
          Map[coords1[I, 0] - 1, coords1[I, 1]] := 1;
          coords2 := coords2 + [[coords1[I, 0] - 1, coords1[I, 1]]];
        end;

      if (coords1[I, 0] < High(Map)) and (Map[coords1[I, 0] + 1, coords1[I, 1]] = 0) then
        if (coords1[I, 0] + 1 = FindY) and (coords1[I, 1] = FindX) then
        begin
          IsPathFinded := True;
          Result := GetLabirintPath(MainMap, StartX, StartY, coords1[I, 1], coords1[I, 0]) + [DirDown];
          Break;
        end
        else
        begin
          Map[coords1[I, 0] + 1, coords1[I, 1]] := 1;
          coords2 := coords2 + [[coords1[I, 0] + 1, coords1[I, 1]]];
        end;

      Map[coords1[I, 0], coords1[I, 1]] := 1;
      Inc(I);
    end;

    coords1 := Copy(coords2);
    SetLength(coords2, 0);
  end;
end;

end.

