unit PauseUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Imaging.GIFImg, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TPauseForm = class(TForm)
    MenuImage: TImage;
    SettingsImage: TImage;
    PauseLabel: TLabel;
    WaitNextKeyTimer: TTimer;
    ResumeImage: TImage;
    procedure MenuImageClick(Sender: TObject);
    procedure MenuImageMouseEnter(Sender: TObject);
    procedure MenuImageMouseLeave(Sender: TObject);
    procedure SettingsImageMouseLeave(Sender: TObject);
    procedure SettingsImageMouseEnter(Sender: TObject);
    procedure WaitNextKeyTimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SettingsImageClick(Sender: TObject);
    procedure ResumeImageMouseLeave(Sender: TObject);
    procedure ResumeImageMouseEnter(Sender: TObject);
    procedure ResumeImageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PauseForm: TPauseForm;

implementation

{$R *.dfm}

uses
  MenuUnit, GameUnit, SettingsUnit, MaskUnit, TypesUnit;

type
  TButton = (BNone, BResume, BSettings, BMenu);

var
  ActiveButton: TButton = BNone;

procedure BackToMenu;
begin
  IsGameStarted := False;
  PauseForm.Hide;
  MaskForm.Hide;
  GameForm.Hide;
  MenuForm.Show;
end;

procedure ResumeGame;
begin
  PauseForm.Hide;
  MaskForm.Hide;
  GameForm.Show;
end;

procedure ShowSettings;
begin
  PauseForm.Hide;
  SettingsForm.Show;
end;

procedure ClearActiveButtons;
begin
  MenuForm.ButtonsVirtList.GetIcon(8, PauseForm.ResumeImage.Picture.Icon);
  MenuForm.ButtonsVirtList.GetIcon(2, PauseForm.SettingsImage.Picture.Icon);
  MenuForm.ButtonsVirtList.GetIcon(6, PauseForm.MenuImage.Picture.Icon);
end;

procedure PaintActiveButton;
begin
  ClearActiveButtons;
  case ActiveButton of
    BResume: MenuForm.ButtonsVirtList.GetIcon(9, PauseForm.ResumeImage.Picture.Icon);
    BSettings: MenuForm.ButtonsVirtList.GetIcon(3, PauseForm.SettingsImage.Picture.Icon);
    BMenu: MenuForm.ButtonsVirtList.GetIcon(7, PauseForm.MenuImage.Picture.Icon);
  end;
end;

procedure TPauseForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TPauseForm.FormHide(Sender: TObject);
begin
  MaskedForm := FNone;
end;

procedure TPauseForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
  begin
    if ActiveButton <> BNone then
      PlayMedia(MenuForm.ButtonClickMedia);
    case ActiveButton of
      BResume: ResumeGame;
      BSettings: ShowSettings;
      BMenu: BackToMenu;
    end;
    ActiveButton := BNone;
  end
  else if not (WaitNextKeyTimer.Enabled) then
    case Key of
      VK_UP, 87:
      begin
        PlayMedia(MenuForm.MenuSwitchMedia);
        if (ActiveButton = BResume) or (ActiveButton = BNone) then
          ActiveButton := BMenu
        else ActiveButton := Pred(ActiveButton);
      end;
      VK_Down, 83:
      begin
        PlayMedia(MenuForm.MenuSwitchMedia);
        if ActiveButton = BMenu then
          ActiveButton := BResume
        else ActiveButton := Succ(ActiveButton);
      end;
      VK_Escape:
      begin
        PlayMedia(MenuForm.ButtonClickMedia);
        ResumeGame;
        ActiveButton := BNone;
      end;
    end;
  PaintActiveButton;
  WaitNextKeyTimer.Enabled := True;
end;

procedure TPauseForm.FormShow(Sender: TObject);
begin
  MaskedForm := FPause;
end;

procedure TPauseForm.MenuImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  BackToMenu;
end;

procedure TPauseForm.MenuImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BMenu;
  PaintActiveButton;
end;

procedure TPauseForm.MenuImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(6, MenuImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TPauseForm.ResumeImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  ResumeGame;
end;

procedure TPauseForm.ResumeImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BResume;
  PaintActiveButton;
end;

procedure TPauseForm.ResumeImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(8, ResumeImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TPauseForm.SettingsImageClick(Sender: TObject);
begin
  PlayMedia(MenuForm.ButtonClickMedia);
  ShowSettings;
end;

procedure TPauseForm.SettingsImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuForm.MenuSwitchMedia);
  ActiveButton := BSettings;
  PaintActiveButton;
end;

procedure TPauseForm.SettingsImageMouseLeave(Sender: TObject);
begin
  MenuForm.ButtonsVirtList.GetIcon(2, SettingsImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TPauseForm.WaitNextKeyTimerTimer(Sender: TObject);
begin
  WaitNextKeyTimer.Enabled := False;
end;

end.
