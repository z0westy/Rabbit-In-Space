unit TypesUnit;

interface

uses
  Vcl.ExtCtrls;

type
  TByte2Array = Array of Array of Byte;
  TByteArray = Array of Byte;
  TWordArray = Array of Word;
  TImageArray = Array of TImage;
  TMapArray = Array [1..10, 1..10] of Byte;
  TMaskedForm = (FNone, FSettings,  FPause, FLoseOrWin);
  TIndicatorColours = (CGreen, CYellow, CRed);
  TDir = (DirDown, DirRight, DirUp, DirLeft);
  TPath = Array of TDir;

type
  TPlut = record
    X, Y, Count: Byte;
  end;

type
  TRoom = record
    SizeX, SizeY: Byte;
    Angle, Value, Tiles: Byte;
  end;

type
  TPlayer = record
    X, Y: Byte;
    LastStep: TDir;
  end;

type
  TFloor = class
    MainRoom, SecondRoom: TRoom;
    MyPlayer: TPlayer;
    Plut: TPlut;
    Map: TMapArray;
    Path: TPath;
    TakenAngles: Array[1..4] of Boolean;
    ColourIndex, LiftAngle, LadderAngle, Steps, NumTiles: Byte;
  end;

implementation
end.
