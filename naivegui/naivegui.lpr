program naivegui;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  start_trd,
  service_state_trd,
  JsonArrayHelper, Unit2 { you can add units after this };

  {$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='NaiveGUI v0.3';
  Application.Scaled:=True;
  {$PUSH}
  {$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TQRForm, QRForm);
  Application.Run;
end.
