program Rabbit_In_Space;



uses
  Vcl.Forms,
  GameUnit in 'GameUnit.pas' {GameForm},
  MenuUnit in 'MenuUnit.pas' {MenuForm},
  PauseUnit in 'PauseUnit.pas' {Form3},
  MaskUnit in 'MaskUnit.pas' {MaskForm},
  LoseOrWinUnit in 'LoseOrWinUnit.pas' {LoseOrWinForm},
  LabirintUnit in 'LabirintUnit.pas',
  TypesUnit in 'TypesUnit.pas',
  WallsUnit in 'WallsUnit.pas',
  CoordUnit in 'CoordUnit.pas',
  RandGenUnit in 'RandGenUnit.pas',
  SettingsUnit in 'SettingsUnit.pas' {SettingsForm},
  GameEventsUnit in 'GameEventsUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMenuForm, MenuForm);
  Application.CreateForm(TGameForm, GameForm);
  Application.CreateForm(TPauseForm, PauseForm);
  Application.CreateForm(TMaskForm, MaskForm);
  Application.CreateForm(TLoseOrWinForm, LoseOrWinForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.Run;
end.
