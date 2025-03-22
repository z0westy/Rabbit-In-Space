unit MenuUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.StdCtrls, Vcl.Imaging.pngimage, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.MPlayer, TypesUnit;

type
  TMenuForm = class(TForm)
    BackgroundImage: TImage;
    PlayImage: TImage;
    ExitImage: TImage;
    SettingsImage: TImage;
    ButtonsCollection: TImageCollection;
    ButtonsVirtList: TVirtualImageList;
    MenuSwitchMedia: TMediaPlayer;
    ButtonClickMedia: TMediaPlayer;
    WaitNextKeyTimer: TTimer;
    procedure PlayImageClick(Sender: TObject);
    procedure ExitImageClick(Sender: TObject);
    procedure PlayImageMouseEnter(Sender: TObject);
    procedure PlayImageMouseLeave(Sender: TObject);
    procedure ExitImageMouseEnter(Sender: TObject);
    procedure ExitImageMouseLeave(Sender: TObject);
    procedure SettingsImageMouseEnter(Sender: TObject);
    procedure SettingsImageMouseLeave(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WaitNextKeyTimerTimer(Sender: TObject);
    procedure SettingsImageClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MenuForm: TMenuForm;
  IsGameStarted: Boolean;
  IsVoiceOn: Boolean = True;
  MaskedForm: TMaskedForm = FNone;

procedure PlayMedia(MediaPlayer: TMediaPlayer);

implementation

{$R *.dfm}

uses
  GameUnit, SettingsUnit, MaskUnit;

type
  TButton = (BNone, BPlay, BSettings, BExit);

var
  ActiveButton: TButton = BNone;

procedure PlayMedia(MediaPlayer: TMediaPlayer);
begin
  if IsVoiceOn then
  begin
    MediaPlayer.Previous;
    MediaPlayer.Play;
  end;
end;

procedure StartGame;
begin
  MenuForm.Hide;
  GameForm.Show;
end;

procedure ShowSettings;
begin
  (MenuForm.BackgroundImage.Picture.Graphic as TGIFImage).Animate := False;
  MaskForm.Show;
  SettingsForm.Show;
end;

procedure ClearActiveButtons;
begin
  MenuForm.ButtonsVirtList.GetIcon(0, MenuForm.PlayImage.Picture.Icon);
  MenuForm.ButtonsVirtList.GetIcon(2, MenuForm.SettingsImage.Picture.Icon);
  MenuForm.ButtonsVirtList.GetIcon(4, MenuForm.ExitImage.Picture.Icon);
end;

procedure PaintActiveButton;
begin
  ClearActiveButtons;
  case ActiveButton of
    BPlay: MenuForm.ButtonsVirtList.GetIcon(1, MenuForm.PlayImage.Picture.Icon);
    BSettings: MenuForm.ButtonsVirtList.GetIcon(3, MenuForm.SettingsImage.Picture.Icon);
    BExit: MenuForm.ButtonsVirtList.GetIcon(5, MenuForm.ExitImage.Picture.Icon);
  end;
end;

procedure TMenuForm.PlayImageClick(Sender: TObject);
begin
  PlayMedia(ButtonClickMedia);
  StartGame;
end;

procedure TMenuForm.PlayImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuSwitchMedia);
  ActiveButton := BPlay;
  PaintActiveButton;
end;

procedure TMenuForm.PlayImageMouseLeave(Sender: TObject);
begin
  ButtonsVirtList.GetIcon(0, PlayImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TMenuForm.SettingsImageClick(Sender: TObject);
begin
  PlayMedia(ButtonClickMedia);
  ShowSettings;
end;

procedure TMenuForm.SettingsImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuSwitchMedia);
  ActiveButton := BSettings;
  PaintActiveButton;
end;

procedure TMenuForm.SettingsImageMouseLeave(Sender: TObject);
begin
  ButtonsVirtList.GetIcon(2, SettingsImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TMenuForm.ExitImageClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMenuForm.ExitImageMouseEnter(Sender: TObject);
begin
  PlayMedia(MenuSwitchMedia);
  ActiveButton := BExit;
  PaintActiveButton;
end;

procedure TMenuForm.ExitImageMouseLeave(Sender: TObject);
begin
  ButtonsVirtList.GetIcon(4, ExitImage.Picture.Icon);
  ActiveButton := BNone;
end;

procedure TMenuForm.FormActivate(Sender: TObject);
begin
  (BackgroundImage.Picture.Graphic as TGIFImage).Animate := True;
end;

procedure TMenuForm.FormCreate(Sender: TObject);
var
  Path: String;
begin
  Path := ExtractFilePath(Application.ExeName);

  ButtonClickMedia.FileName := Path + 'sounds\' + 'button_click.mp3';
  MenuSwitchMedia.FileName := Path + 'sounds\' + 'menu_switch.mp3';

  ButtonClickMedia.Open;
  MenuSwitchMedia.Open;
end;

procedure TMenuForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
  begin
    if ActiveButton <> BNone then
      PlayMedia(ButtonClickMedia);
    case ActiveButton of
      BPlay: StartGame;
      BSettings: ShowSettings;
      BExit: Application.Terminate;
    end;
    ActiveButton := BNone;
  end
  else if not (WaitNextKeyTimer.Enabled) then
    case Key of
      VK_UP, 87:
      begin
        PlayMedia(MenuSwitchMedia);
        if (ActiveButton = BPlay) or (ActiveButton = BNone) then
          ActiveButton := BExit
        else ActiveButton := Pred(ActiveButton);
      end;
      VK_Down, 83:
      begin
        PlayMedia(MenuSwitchMedia);
        if ActiveButton = BExit then
          ActiveButton := BPlay
        else ActiveButton := Succ(ActiveButton);
      end;
    end;
  PaintActiveButton;
  WaitNextKeyTimer.Enabled := True;
end;

procedure TMenuForm.WaitNextKeyTimerTimer(Sender: TObject);
begin
  WaitNextKeyTimer.Enabled := False;
end;

end.
