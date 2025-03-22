unit GameUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, System.ImageList, Vcl.ImgList, Vcl.Grids,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImageList,
  Vcl.CheckLst, Vcl.Imaging.GIFImg, Vcl.MPlayer, TypesUnit;

type
  TGameForm = class(TForm)
    FieldImage: TImage;
    LiftImage: TImage;
    LadderImage: TImage;
    PlayerImage: TImage;
    IndicatorTimer: TTimer;
    PlayerImagesList: TImageList;
    PlayerAnimTimer: TTimer;
    PlayerMoveTimer: TTimer;
    PlayerAfkAnimTimer: TTimer;
    LadderAnimTimer: TTimer;
    LadderImagesList: TImageList;
    FieldImagesVirtList: TVirtualImageList;
    FieldCollection: TImageCollection;
    BackgroundImage: TImage;
    TileImagesList: TImageList;
    PlutImage: TImage;
    DirImagesList: TImageList;
    DirImage: TImage;
    LiftImagesList: TImageList;
    LiftAnimTimer: TTimer;
    VoiceImage: TImage;
    MenuImage: TImage;
    PauseImage: TImage;
    DirHeadLabel: TLabel;
    DirLabel: TLabel;
    SquareImagesCollection: TImageCollection;
    SquareImagesVirtList: TVirtualImageList;
    FloorNumLabel: TLabel;
    FloorTitleLabel: TLabel;
    PlutMedia: TMediaPlayer;
    WinMedia: TMediaPlayer;
    LoseMedia: TMediaPlayer;
    NewFloorMedia: TMediaPlayer;
    StepMedia: TMediaPlayer;
    IndicatorImage: TImage;
    IndicatorCollection: TImageCollection;
    IndicatorVirtList: TVirtualImageList;
    LoseTimer: TTimer;
    BackgroundPartImage: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure IndicatorTimerTimer(Sender: TObject);
    procedure PlayerAnimTimerTimer(Sender: TObject);
    procedure PlayerMoveTimerTimer(Sender: TObject);
    procedure PlayerAfkAnimTimerTimer(Sender: TObject);
    procedure LadderAnimTimerTimer(Sender: TObject);
    procedure LiftAnimTimerTimer(Sender: TObject);
    procedure PauseImageClick(Sender: TObject);
    procedure MenuImageClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VoiceImageMouseEnter(Sender: TObject);
    procedure VoiceImageMouseLeave(Sender: TObject);
    procedure PauseImageMouseEnter(Sender: TObject);
    procedure PauseImageMouseLeave(Sender: TObject);
    procedure MenuImageMouseEnter(Sender: TObject);
    procedure MenuImageMouseLeave(Sender: TObject);
    procedure VoiceImageClick(Sender: TObject);
    procedure LoseTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GameForm: TGameForm;
  MyFloor: TFloor;
  TileImagesArray: Array of TImage;
  IsLiftUsed: Boolean;

implementation

{$R *.dfm}

uses
  MenuUnit, PauseUnit, LoseOrWinUnit, MaskUnit, LabirintUnit, CoordUnit,
  WallsUnit, RandGenUnit, DirectionUnit, GameEventsUnit;

var
  IndicatorColour, PrevIndicatorColour: TIndicatorColours;
  TakenColours: Array[0..6] of Boolean;
  PlayerPos: Array[1..2] of Byte;
  EndX, EndY: Word;
  LiftAngle, NumFloor: Byte;
  PlayerChanges, LadderChanges, LiftChanges: Byte;
  AfkPlayerAnim, IsAfkWait: Boolean;

procedure TurnOffVoice;
begin
  GameForm.NewFloorMedia.Stop;
  GameForm.PlutMedia.Stop;
  GameForm.WinMedia.Stop;
  GameForm.LoseMedia.Stop;
  GameForm.StepMedia.Stop;
end;

procedure MovePlayer(EndX: Word; EndY: Word);
var
  I: Byte;
  IsStepCompleted: Boolean;
begin
  IsStepCompleted := False;
  case MyFloor.MyPlayer.LastStep of
    DirUp:
    if GameForm.PlayerImage.Top > EndY then
      GameForm.PlayerImage.Top := GameForm.PlayerImage.Top - 2
    else IsStepCompleted := True;
    DirRight:
    if GameForm.PlayerImage.Left < EndX then
      GameForm.PlayerImage.Left := GameForm.PlayerImage.Left + 2
    else IsStepCompleted := True;
    DirDown:
    if GameForm.PlayerImage.Top < EndY then
      GameForm.PlayerImage.Top := GameForm.PlayerImage.Top + 2
    else IsStepCompleted := True;
    DirLeft:
    if GameForm.PlayerImage.Left > EndX then
      GameForm.PlayerImage.Left := GameForm.PlayerImage.Left - 2
    else IsStepCompleted := True;
  end;

  if IsStepCompleted then
  begin
    GameForm.PlayerAnimTimer.Enabled := False;
    GameForm.PlayerImagesList.GetIcon(ConvertDirToNum(MyFloor.MyPlayer.LastStep),
                                      GameForm.PlayerImage.Picture.Icon);
    GameForm.PlayerMoveTimer.Enabled := False;

    if MyFloor.MyPlayer.LastStep <> MyFloor.Path[MyFloor.Steps-1] then
      ShowLoseOrWinForm(False, IsAfkWait)
    else
    begin
      GameForm.PlayerAfkAnimTimer.Enabled := True;

      if MyFloor.Plut.Count <= 2 then
        if (MyFloor.MyPlayer.X = MyFloor.Plut.X) and (MyFloor.MyPlayer.Y = MyFloor.Plut.Y) then
        begin
          PlayMedia(GameForm.PlutMedia);
          Inc(MyFloor.Plut.Count);
          MyFloor.Steps := 0;
          if MyFloor.Plut.Count = 2 then
          begin
            GameForm.PlutImage.Visible := False;
            if (IsLiftUsed) then
              MyFloor.Path := GetLabirintPath(MyFloor.Map, MyFloor.MyPlayer.X, MyFloor.MyPlayer.Y,
                AngleToCoord(MyFloor.LadderAngle)[0],
                AngleToCoord(MyFloor.LadderAngle)[1])
            else
              MyFloor.Path := GetLabirintPath(MyFloor.Map, MyFloor.MyPlayer.X, MyFloor.MyPlayer.Y,
                              AngleToCoord(MyFloor.LiftAngle)[0],
                              AngleToCoord(MyFloor.LiftAngle)[1]);
          end
          else
          begin
            GenerateNewPlut;
            MyFloor.Path := GetLabirintPath(MyFloor.Map, MyFloor.MyPlayer.X, MyFloor.MyPlayer.Y,
                    MyFloor.Plut.X, MyFloor.Plut.Y);
          end;
        end
      else if CheckOnNewFloor then
        if NumFloor = 7 then
          ShowLoseOrWinForm(True, IsAfkWait)
        else
        begin
          PlayMedia(GameForm.NewFloorMedia);
          if IsLiftUsed then
            Inc(NumFloor)
          else
          begin
            IsLiftUsed := True;
            NumFloor := NumFloor + 1 + Random(2);
            GameForm.LiftAnimTimer.Enabled := False;
            GameForm.LiftImagesList.GetIcon(6, GameForm.LiftImage.Picture.Icon);
          end;
          GameForm.FloorNumLabel.Caption := IntToStr(NumFloor);
          PlayerPos[1] := MyFloor.MyPlayer.X;
          PlayerPos[2] := MyFloor.MyPlayer.Y;

          MyFloor := TFloor.Create;

          MyFloor.MyPlayer.X := PlayerPos[1];
          MyFloor.MyPlayer.Y := PlayerPos[2];

          GenFloorComponents(TakenColours, LiftAngle, False);
        end;

      if IsGameStarted then
        DirectionOutput;

      if IsAfkWait then
      begin
        IsAfkWait := False;
        GameForm.PlayerAfkAnimTimer.Enabled := False;
      end;
    end;
  end;
end;

procedure TGameForm.PauseImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  if not (PlayerAfkAnimTimer.Enabled) then
    IsAfkWait := True;
  ShowPauseForm;
end;

procedure TGameForm.PauseImageMouseEnter(Sender: TObject);
begin
  SquareImagesVirtList.GetIcon(3, PauseImage.Picture.Icon);
end;

procedure TGameForm.PauseImageMouseLeave(Sender: TObject);
begin
  SquareImagesVirtList.GetIcon(2, PauseImage.Picture.Icon);
end;

procedure TGameForm.MenuImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  BackToMenu;
end;

procedure TGameForm.MenuImageMouseEnter(Sender: TObject);
begin
  SquareImagesVirtList.GetIcon(5, MenuImage.Picture.Icon);
end;

procedure TGameForm.MenuImageMouseLeave(Sender: TObject);
begin
  SquareImagesVirtList.GetIcon(4, MenuImage.Picture.Icon);
end;

procedure TGameForm.VoiceImageClick(Sender: TObject);
begin
  MenuForm.ButtonClickMedia.Play;
  if IsVoiceOn then
  begin
    SquareImagesVirtList.GetIcon(7, VoiceImage.Picture.Icon);
    IsVoiceOn := False;
    TurnOffVoice;
  end
  else
  begin
    SquareImagesVirtList.GetIcon(0, VoiceImage.Picture.Icon);
    IsVoiceOn := True;
  end;
end;

procedure TGameForm.VoiceImageMouseEnter(Sender: TObject);
begin
  if IsVoiceOn then
    SquareImagesVirtList.GetIcon(1, VoiceImage.Picture.Icon)
  else
    SquareImagesVirtList.GetIcon(6, VoiceImage.Picture.Icon);
end;

procedure TGameForm.VoiceImageMouseLeave(Sender: TObject);
begin
  if IsVoiceOn then
    SquareImagesVirtList.GetIcon(0, VoiceImage.Picture.Icon)
  else
    SquareImagesVirtList.GetIcon(7, VoiceImage.Picture.Icon);
end;

procedure TGameForm.FormActivate(Sender: TObject);
begin
  (BackgroundImage.Picture.Graphic as TGIFImage).Animate := True;

  if not (IsGameStarted) then
  begin
    IsGameStarted := True;
    IsLiftUsed := False;

    MyFloor := TFloor.Create;

    PlayerImagesList.GetIcon(0, PlayerImage.Picture.Icon);

    NumFloor := Random(3) + 1;
    FloorNumLabel.Caption := IntToStr(NumFloor);

    GenFloorComponents(TakenColours, LiftAngle, True);

    DirectionOutput;

    MyFloor.MyPlayer.LastStep := DirDown;

    PlayMedia(NewFloorMedia);

    IndicatorColour := CYellow;
    PrevIndicatorColour := CRed;
    IndicatorVirtList.GetIcon(0, IndicatorImage.Picture.Icon);
  end;

  LadderAnimTimer.Enabled := True;
  LiftAnimTimer.Enabled := True;
  IndicatorTimer.Enabled := True;
  PlayerAfkAnimTimer.Enabled := True;
end;

procedure TGameForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TGameForm.FormCreate(Sender: TObject);
var
  Path: String;
begin
  Path := ExtractFilePath(Application.ExeName);

  LoseMedia.FileName := Path + 'sounds\' + 'lose_sound.mp3';
  NewFloorMedia.FileName := Path + 'sounds\' + 'new_floor_sound.mp3';
  PlutMedia.FileName := Path + 'sounds\' + 'plut_sound.mp3';
  StepMedia.FileName := Path + 'sounds\' + 'step_sound.mp3';
  WinMedia.FileName := Path + 'sounds\' + 'win_sound.mp3';

  LoseMedia.Open;
  NewFloorMedia.Open;
  PlutMedia.Open;
  StepMedia.Open;
  WinMedia.Open;

  AddFontResourceEx(PWideChar(Path + 'font\' + 'FontMinecraft.ttf'), FR_PRIVATE, nil);

  Randomize;
end;

procedure TGameForm.FormHide(Sender: TObject);
begin
  IsGameStarted := False;
end;

procedure TGameForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Buf: TWordArray;
  IsNewStep: Boolean;
begin
  IsNewStep := False;

  if Key = VK_Escape then
  begin
    if not (PlayerAfkAnimTimer.Enabled) then
      IsAfkWait := True;
    PlayMedia(MenuForm.ButtonClickMedia);
    ShowPauseForm;
  end
  else if not ((PlayerAnimTimer.Enabled) or (PlayerMoveTimer.Enabled)) then
    case Key of
      VK_UP, 87:
        if (MyFloor.MyPlayer.Y > Low(MyFloor.Map)) and
           (MyFloor.Map[MyFloor.MyPlayer.Y-1, MyFloor.MyPlayer.X] = 0) then
        begin
          Dec(MyFloor.MyPlayer.Y);
          MyFloor.MyPlayer.LastStep := DirUp;
          IsNewStep := True;
        end;
      VK_Down, 83:
        if (MyFloor.MyPlayer.Y < High(MyFloor.Map)) and
           (MyFloor.Map[MyFloor.MyPlayer.Y+1, MyFloor.MyPlayer.X] = 0) then
        begin
          Inc(MyFloor.MyPlayer.Y);
          MyFloor.MyPlayer.LastStep := DirDown;
          IsNewStep := True;
        end;
      VK_Left, 65:
        if (MyFloor.MyPlayer.X > Low(MyFloor.Map[1])) and
           (MyFloor.Map[MyFloor.MyPlayer.Y, MyFloor.MyPlayer.X-1] = 0) then
        begin
          Dec(MyFloor.MyPlayer.X);
          MyFloor.MyPlayer.LastStep := DirLeft;
          IsNewStep := True;
        end;
      VK_Right, 68:
        if (MyFloor.MyPlayer.X < High(MyFloor.Map[1])) and
           (MyFloor.Map[MyFloor.MyPlayer.Y, MyFloor.MyPlayer.X+1] = 0) then
        begin
          Inc(MyFloor.MyPlayer.X);
          MyFloor.MyPlayer.LastStep := DirRight;
          IsNewStep := True;
        end;
  end;

  if IsNewStep then
  begin
    PlayMedia(StepMedia);

    if IndicatorColour = CRed then
      LoseTimer.Enabled := True;

    Inc(MyFloor.Steps);

    Buf := GetLeftUpAngle(MyFloor.MyPlayer.X, MyFloor.MyPlayer.Y);

    EndX := Buf[0] + 12;
    EndY := Buf[1] + 12;

    PlayerAfkAnimTimer.Enabled := False;
    PlayerMoveTimer.Enabled := True;
    PlayerAnimTimer.Enabled := True;
  end;
end;

procedure TGameForm.LadderAnimTimerTimer(Sender: TObject);
begin
  LadderAnimTimer.Interval := 200;
  LadderImagesList.GetIcon(LadderChanges, LadderImage.Picture.Icon);
  if LadderChanges = 7 then
    LadderChanges := 0
  else Inc(LadderChanges);
end;

procedure TGameForm.IndicatorTimerTimer(Sender: TObject);
begin
  case IndicatorColour of
    CRed:
    begin
      IndicatorColour := CYellow;
      PrevIndicatorColour := CRed;
      IndicatorVirtList.GetIcon(3, IndicatorImage.Picture.Icon);
      IndicatorTimer.Interval := Random(500) + 750;
    end;
    CGreen:
    begin
      IndicatorColour := CYellow;
      PrevIndicatorColour := CGreen;
      IndicatorVirtList.GetIcon(3, IndicatorImage.Picture.Icon);
      IndicatorTimer.Interval := Random(500) + 750;
    end;
    CYellow:
    if PrevIndicatorColour = CRed then
    begin
      IndicatorColour := CGreen;
      IndicatorVirtList.GetIcon(1, IndicatorImage.Picture.Icon);
      IndicatorTimer.Interval := Random(2000) + 2000;
    end
    else
    begin
      IndicatorColour := CRed;
      IndicatorVirtList.GetIcon(2, IndicatorImage.Picture.Icon);
      IndicatorTimer.Interval := Random(750) + 750;
      if PlayerMoveTimer.Enabled then
        LoseTimer.Enabled := True;
    end;
  end;
end;

procedure TGameForm.LiftAnimTimerTimer(Sender: TObject);
begin
  LiftAnimTimer.Interval := 200;
  LiftImagesList.GetIcon(LiftChanges, LiftImage.Picture.Icon);
  if LiftChanges = 7 then
    LiftChanges := 0
  else Inc(LiftChanges);
end;

procedure TGameForm.LoseTimerTimer(Sender: TObject);
begin
  ShowLoseOrWinForm(False, IsAfkWait);
  LoseTimer.Enabled := False;
end;

procedure TGameForm.PlayerAfkAnimTimerTimer(Sender: TObject);
begin
  if AfkPlayerAnim then
  begin
    PlayerImagesList.GetIcon(16 + ConvertDirToNum(MyFloor.MyPlayer.LastStep) div 4, PlayerImage.Picture.Icon);
    AfkPlayerAnim := False;
  end
  else
  begin
    PlayerImagesList.GetIcon(ConvertDirToNum(MyFloor.MyPlayer.LastStep), PlayerImage.Picture.Icon);
    AfkPlayerAnim := True;
  end;
end;

procedure TGameForm.PlayerAnimTimerTimer(Sender: TObject);
begin
  PlayerAnimTimer.Interval := 80;
  PlayerImagesList.GetIcon(PlayerChanges + ConvertDirToNum(MyFloor.MyPlayer.LastStep),
                           PlayerImage.Picture.Icon);
  if PlayerChanges = 3 then
    PlayerChanges := 0
  else Inc(PlayerChanges);
end;

procedure TGameForm.PlayerMoveTimerTimer(Sender: TObject);
begin
  MovePlayer(EndX, EndY);
end;

end.
