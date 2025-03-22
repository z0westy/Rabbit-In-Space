unit LoseOrWinUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.BaseImageCollection, Vcl.ImageCollection, System.ImageList,
  Vcl.ImgList, Vcl.VirtualImageList, Vcl.MPlayer;

type
  TLoseOrWinForm = class(TForm)
    ResultLabel: TLabel;
    NewGameImage: TImage;
    MenuImage: TImage;
    SettingsImage: TImage;
    WaitNextKeyTimer: TTimer;
    procedure NewGameImageMouseEnter(Sender: TObject);
    procedure NewGameImageMouseLeave(Sender: TObject);
    procedure SettingsImageMouseLeave(Sender: TObject);
    procedure MenuImageMouseLeave(Sender: TObject);
    procedure SettingsImageMouseEnter(Sender: TObject);
    procedure MenuImageMouseEnter(Sender: TObject);
    procedure MenuImageClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WaitNextKeyTimerTimer(Sender: TObject);
    procedure NewGameImageClick(Sender: TObject);
    procedure SettingsImageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoseOrWinForm: TLoseOrWinForm;

implementation

{$R *.dfm}

uses
  MenuUnit, GameUnit, SettingsUnit, MaskUnit, TypesUnit;

type
  TButton = (BNone, BNewGame, BSettings, BMenu);

var
  ActiveButton: TButton = BNone;

procedure StartNewGame;
begin
  LoseOrWinForm.Hide;
  MaskForm.Hide;
end;

procedure BackToMenu;
begin
  LoseOrWinForm.Hide;
  MaskForm.Hide;
  GameForm.Hide;
  MenuForm.Show;
end;

procedure ShowSettings;
begin
  LoseOrWinForm.Hide;
  SettingsForm.Show;
end;

procedure ClearActiveButtons;
begin
  MenuForm.ButtonsVirtList.GetIcon(10, LoseOrWinForm.NewGameImage.Picture.Icon);
  MenuForm.ButtonsVirtList.GetIcon(2, LoseOrWinForm.SettingsImage.Picture.Icon);
  MenuForm.ButtonsVirtList.GetIcon(6, LoseOrWinForm.MenuImage.Picture.Icon);
end;

procedure PaintActiveButton;
begin
  ClearActiveButtons;
  case ActiveButton of
    BNewGame: MenuForm.ButtonsVirtList.GetIcon(11, LoseOrWinForm.NewGameImage.Picture.Icon);
    BSettings: MenuForm.ButtonsVirtList.GetIcon(3, LoseOrWinForm.SettingsImage.Picture.Icon);
    BMenu: MenuForm.ButtonsVirtList.GetIcon(7, LoseOrWinForm.MenuImage.Picture.Icon);
  end;
end;

procedure TLoseOrWinForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TLoseOrWinForm.FormHide(Sender: TObject);
begin
  MaskedForm := FNone;
end;

procedure TLoseOrWinForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
  begin
    if ActiveButton <> BNone then
      PlayMedia(MenuForm.ButtonClickMedia);
    case ActiveButton of
      BNewGame: StartNewGame;
      BSettings: ShowSettings;
      BMenu: BackToMenu;
    end;
    ActiveButton := BNone;
  end
  else if not (WaitNextKeyTimer.Enabled) then
    case Key of
      VK_UP, 87:
      begin
        PlayMedia(MenuForm.MenuSwitchMedia);;
        if (ActiveButton = BNewGame) or (ActiveButton = BNone) then
          ActiveButton := BMenu
        else ActiveButton := Pred(ActiveButton);
      end;
      VK_Down, 83:
      begin
        PlayMedia(MenuForm.MenuSwitchMedia);
        if ActiveButton = BMenu then
          ActiveButton := BNewGame
        else ActiveButton := Succ(ActiveButton);
      end;
    end;
  PaintActiveButton;
  WaitNextKeyTimer.Enabled := True;
end;

procedure TLoseOrWinForm.FormShow(Sender: TObject);
begin
  MaskedForm := FLoseOrWin;
end;

procedure TLoseOrWinForm.MenuImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  BackToMenu;
end;

procedure TLoseOrWinForm.MenuImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BMenu;
  PaintActiveButton;
end;

procedure TLoseOrWinForm.MenuImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(6, MenuImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TLoseOrWinForm.NewGameImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  StartNewGame;
end;

procedure TLoseOrWinForm.NewGameImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BNewGame;
  PaintActiveButton;
end;

procedure TLoseOrWinForm.NewGameImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(10, NewGameImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TLoseOrWinForm.SettingsImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  ShowSettings;
end;

procedure TLoseOrWinForm.SettingsImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BSettings;
  PaintActiveButton;
end;

procedure TLoseOrWinForm.SettingsImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(2, SettingsImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TLoseOrWinForm.WaitNextKeyTimerTimer(Sender: TObject);
begin
  WaitNextKeyTimer.Enabled := False;
end;

end.
