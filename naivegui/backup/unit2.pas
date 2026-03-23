unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ubarcodes;

type

  { TQRForm }

  TQRForm = class(TForm)
    BarcodeQR1: TBarcodeQR;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  QRForm: TQRForm;

implementation

{$R *.lfm}

{ TQRForm }

procedure TQRForm.FormShow(Sender: TObject);
begin
  QRForm.Width:=QRForm.Height;
end;

end.

