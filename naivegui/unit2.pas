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

uses unit1;

  {$R *.lfm}

  { TQRForm }

procedure TQRForm.FormShow(Sender: TObject);
begin
  //Квадрат
  QRForm.Width := QRForm.Height;

  //В центр
  QRForm.Left := MainForm.Left + MainForm.Width div 2 - QRForm.Width div 2;
  QRForm.Top := MainForm.Top + MainForm.Height div 2 - QRForm.Height div 2;
end;

end.
