unit SettingsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Imaging.GIFImg;

type
  TSettingsForm = class(TForm)
    BackImage: TImage;
    ResultLabel: TLabel;
    WaitNextKeyTimer: TTimer;
    procedure BackImageClick(Sender: TObject);
    procedure BackImageMouseEnter(Sender: TObject);
    procedure BackImageMouseLeave(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WaitNextKeyTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.dfm}

uses
  MenuUnit, GameUnit, PauseUnit, LoseOrWinUnit, MaskUnit, TypesUnit;

type
  TButton = (BNone, BBack);

var
  ActiveButton: TButton = BNone;

procedure ClearActiveButtons;
begin
  MenuForm.ButtonsVirtList.GetIcon(12, SettingsForm.BackImage.Picture.Icon);
end;

procedure PaintActiveButtons;
begin
  ClearActiveButtons;
  case ActiveButton of
    BBack: MenuForm.ButtonsVirtList.GetIcon(13, SettingsForm.BackImage.Picture.Icon);
  end;
end;

procedure ClickBack;
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  if IsGameStarted then
  begin
    SettingsForm.Hide;
    PauseForm.Show;
  end
  else if MenuForm.Visible then
  begin
    SettingsForm.Hide;
    MaskForm.Hide;
  end
  else
  begin
    SettingsForm.Hide;
    LoseOrWinForm.Show;
  end;
end;

procedure TSettingsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TSettingsForm.FormHide(Sender: TObject);
begin
  MaskedForm := FNone;
end;

procedure TSettingsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
  begin
    if ActiveButton <> BNone then
      PlayMedia(MenuForm.ButtonClickMedia);
    case ActiveButton of
      BBack: ClickBack;
    end;
    ActiveButton := BNone;
  end
  else if not (WaitNextKeyTimer.Enabled) then
    case Key of
      VK_UP, 87:
      begin
        PlayMedia(MenuForm.MenuSwitchMedia);
        if ActiveButton = BNone then
          ActiveButton := BBack
        else ActiveButton := Pred(ActiveButton);
      end;
      VK_Down, 83:
      begin
        PlayMedia(MenuForm.MenuSwitchMedia);
        if ActiveButton = BBack then
          ActiveButton := BNone
        else ActiveButton := Succ(ActiveButton);
      end;
      VK_Escape:
      begin
        PlayMedia(MenuForm.ButtonClickMedia);
        ClickBack;
        ActiveButton := BNone;
      end;
  end;
  PaintActiveButtons;
  WaitNextKeyTimer.Enabled := True;
end;

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  MaskedForm := FSettings;
end;

procedure TSettingsForm.WaitNextKeyTimerTimer(Sender: TObject);
begin
  WaitNextKeyTimer.Enabled := False;
end;

procedure TSettingsForm.BackImageClick(Sender: TObject);
begin
  ClickBack;
end;

procedure TSettingsForm.BackImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BBack;
  PaintActiveButtons;
end;

procedure TSettingsForm.BackImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(12, SettingsForm.BackImage.Picture.Icon);
  ActiveButton := BNone;
end;

end.
