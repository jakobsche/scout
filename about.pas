unit About;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  AboutBox: TAboutBox;

implementation

uses LCLIntf;

{$R *.lfm}

{ TAboutBox }

procedure TAboutBox.BitBtn1Click(Sender: TObject);
begin
  Close
end;

procedure TAboutBox.BitBtn2Click(Sender: TObject);
begin
  OpenURL('mailto:jakobschea@aim.com'{?subject="Betrifft Scout"'})
    {funktioniert nicht mit Parametern (auch OpenDocument)}
    {OpenDocument funktioniert nicht mit Linux}
end;

procedure TAboutBox.Label1Click(Sender: TObject);
begin

end;

end.

