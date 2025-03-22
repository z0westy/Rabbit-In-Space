unit GameEventsUnit;

interface

uses
  Vcl.Imaging.GIFImg;

procedure StopAllEvents;
procedure ShowPauseForm;
procedure ShowLoseOrWinForm(IsWin: Boolean; var IsAfkWait: Boolean);
procedure BackToMenu;

implementation

uses
  MenuUnit, GameUnit, PauseUnit, LoseOrWinUnit, SettingsUnit, MaskUnit;

procedure StopAllEvents;
begin
  (GameForm.BackgroundImage.Picture.Graphic as TGIFImage).Animate := False;
  GameForm.LadderAnimTimer.Enabled := False;
  GameForm.LiftAnimTimer.Enabled := False;
  GameForm.IndicatorTimer.Enabled := False;
  GameForm.PlayerAfkAnimTimer.Enabled := False;
end;

procedure ShowPauseForm;
begin
  StopAllEvents;
  MaskForm.Show;
  PauseForm.Show;
end;

procedure ShowLoseOrWinForm(IsWin: Boolean; var IsAfkWait: Boolean);
begin
  IsGameStarted := False;
  if IsWin then
  begin
    PlayMedia(GameForm.WinMedia);
    LoseOrWinForm.ResultLabel.Caption := 'Вы выиграли!';
  end
  else
  begin
    PlayMedia(GameForm.LoseMedia);
    LoseOrWinForm.ResultLabel.Caption := 'Вы проиграли!';
  end;

  if not (GameForm.PlayerAfkAnimTimer.Enabled) then
    IsAfkWait := True;

  StopAllEvents;
  SettingsForm.Hide;
  PauseForm.Hide;
  MaskForm.Show;
  LoseOrWinForm.Show;
end;

procedure BackToMenu;
begin
  GameForm.Hide;
  MenuForm.Show;
end;

end.
