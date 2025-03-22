unit MaskUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TMaskForm = class(TForm)
    BackgroundImage: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MaskForm: TMaskForm;

implementation

{$R *.dfm}

uses
  MenuUnit, SettingsUnit, PauseUnit, LoseOrWinUnit, TypesUnit;

procedure TMaskForm.FormActivate(Sender: TObject);
begin
  case MaskedForm of
    FSettings: SettingsForm.SetFocus;
    FPause: PauseForm.SetFocus;
    FLoseOrWin: LoseOrWinForm.SetFocus;
  end;
end;

procedure TMaskForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

end.
