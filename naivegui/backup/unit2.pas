unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ubarcodes;

type

  { TQRForm }

  TQRForm = class(TForm)
    BarcodeQR1: TBarcodeQR;
  private

  public

  end;

var
  QRForm: TQRForm;

implementation

{$R *.lfm}

end.

