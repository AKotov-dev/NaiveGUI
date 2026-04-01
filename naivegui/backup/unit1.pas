unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, DefaultTranslator, IniPropStorage, LCLIntf, StrUtils, FileUtil, Process;

type

  { TMainForm }

  TMainForm = class(TForm)
    Image1: TImage;
    IniPropStorage1: TIniPropStorage;
    Label10: TLabel;
    Label2: TLabel;
    QUICBox: TCheckBox;
    BypassBox: TComboBox;
    DomainEdit: TEdit;
    PassBtn: TSpeedButton;
    SaveDialog1: TSaveDialog;
    QRBtn: TSpeedButton;
    SPortEdit: TEdit;
    HPortEdit: TEdit;
    Label11: TLabel;
    LogMemo: TMemo;
    Shape1: TShape;
    StaticText1: TStaticText;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    UserEdit: TEdit;
    PasswordEdit: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    StartBtn: TSpeedButton;
    StopBtn: TSpeedButton;
    CreateBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure Label10MouseEnter(Sender: TObject);
    procedure Label10MouseLeave(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label2MouseEnter(Sender: TObject);
    procedure Label2MouseLeave(Sender: TObject);
    procedure PassBtnClick(Sender: TObject);
    procedure CreateBtnClick(Sender: TObject);
    procedure QRBtnClick(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure CreateClientConfig;
    procedure CreateServerConfig;
    procedure CreateSWProxy;
    procedure StartProcess(command: string);

  private

  public

  end;

var
  MainForm: TMainForm;

resourcestring
  SNoConfiguration = 'To run, you need to create a configuration!';
  SConfigutarionFound = 'The configuration has already been created! Overwrite?';

implementation

uses start_trd, service_state_trd, JsonArrayHelper, Unit2;

  {$R *.lfm}

  { TMainForm }

//Общая процедура запуска команд (асинхронная)
procedure TMainForm.StartProcess(command: string);
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);
    ExProcess.Options := ExProcess.Options + [poWaitOnExit];
    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

//Create ~/config/naivegui/swproxy.sh
procedure TMainForm.CreateSWProxy;
var
  S: ansistring;
  A: TStringList;
begin
  try
    A := TStringList.Create;
    A.Add('#!/bin/bash');
    A.Add('');
    A.Add('if [[ "$1" == "set" ]]; then');
    A.Add('  echo "set proxy..."');
    A.Add('');
    A.Add('  # GNOME / GTK-based');
    A.Add('  if [[ "$XDG_CURRENT_DESKTOP" =~ GNOME|Budgie|Cinnamon|MATE|XFCE|LXDE ]]; then');
    A.Add('    gsettings set org.gnome.system.proxy mode manual');
    A.Add('    gsettings set org.gnome.system.proxy.http  host "127.0.0.1"');
    A.Add('    gsettings set org.gnome.system.proxy.http  port ' + HPortEdit.Text);
    A.Add('    gsettings set org.gnome.system.proxy.https host "127.0.0.1"');
    A.Add('    gsettings set org.gnome.system.proxy.https port ' + HPortEdit.Text);
    A.Add('    gsettings set org.gnome.system.proxy.ftp   host "127.0.0.1"');
    A.Add('    gsettings set org.gnome.system.proxy.ftp   port ' + HPortEdit.Text);
    A.Add('    gsettings set org.gnome.system.proxy.socks host "127.0.0.1"');
    A.Add('    gsettings set org.gnome.system.proxy.socks port ' + SPortEdit.Text);
    A.Add('    gsettings set org.gnome.system.proxy ignore-hosts "[' +
      '''' + 'localhost' + '''' + ', ' + '''' + '127.0.0.1' + '''' +
      ', ' + '''' + '::1' + '''' + ']"');
    A.Add('  fi');
    A.Add('');
    A.Add('  # KDE Plasma');
    A.Add('  if [[ "$XDG_CURRENT_DESKTOP" == KDE ]]; then');
    A.Add('    if command -v kwriteconfig5 >/dev/null; then');
    A.Add('      v=5');
    A.Add('    elif command -v kwriteconfig6 >/dev/null; then');
    A.Add('      v=6');
    A.Add('    else');
    A.Add('      echo "No kwriteconfig found"');
    A.Add('      exit 1');
    A.Add('  fi');
    A.Add('');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key ProxyType 1');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key httpProxy  "http://127.0.0.1:' + HPortEdit.Text + '"');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key httpsProxy "http://127.0.0.1:' + HPortEdit.Text + '"');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key ftpProxy   "http://127.0.0.1:' + HPortEdit.Text + '"');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key socksProxy "socks5h://127.0.0.1:' + SPortEdit.Text + '"');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key NoProxy    "['
      + '''' + 'localhost' + '''' + ', ' + '''' + '127.0.0.1' + '''' +
      ', ' + '''' + '::1' + '''' + ']"');
    A.Add('  fi');
    A.Add('else');
    A.Add('  echo "unset proxy..."');
    A.Add('');
    A.Add('  # GNOME / GTK-based');
    A.Add('  if [[ "$XDG_CURRENT_DESKTOP" =~ GNOME|Budgie|Cinnamon|MATE|XFCE|LXDE ]]; then');
    A.Add('    gsettings set org.gnome.system.proxy mode none');
    A.Add('  fi');
    A.Add('');
    A.Add('  # KDE Plasma');
    A.Add('  if [[ "$XDG_CURRENT_DESKTOP" == KDE ]]; then');
    A.Add('    if command -v kwriteconfig5 >/dev/null; then');
    A.Add('      v=5');
    A.Add('    elif command -v kwriteconfig6 >/dev/null; then');
    A.Add('      v=6');
    A.Add('    else');
    A.Add('      echo "No kwriteconfig found"');
    A.Add('      exit 1');
    A.Add('    fi');
    A.Add('');
    A.Add('    kwriteconfig$v --file kioslaverc --group "Proxy Settings" --key ProxyType 0');
    A.Add('  fi');
    A.Add('fi');
    A.Add('');

    A.SaveToFile(GetUserDir + '.config/naivegui/swproxy.sh');
    RunCommand('/bin/bash', ['-c', 'chmod +x ~/.config/naivegui/swproxy.sh'], S);
  finally
    A.Free;
  end;
end;

//Создаём конфиг клиента
procedure TMainForm.CreateClientConfig;
var
  S: TStringList;
begin
  try
    S := TStringList.Create;
    S.Add('{');
    S.Add('  "log": {');
    S.Add('    "level": "info"');
    S.Add('  },');
    S.Add('');
    S.Add('  "dns": {');
    S.Add('    "servers": [');
    S.Add('      { "tag": "remote", "type": "udp", "server": "1.1.1.1" },');
    S.Add('      { "tag": "local",  "type": "udp", "server": "8.8.4.4" }');
    S.Add('    ],');
    S.Add('    "rules": [');
    S.Add('      { "domain_suffix": ["' + BypassBox.Text + '"], "server": "local" }');
    S.Add('    ]');
    S.Add('  },');
    S.Add('');
    S.Add('  "inbounds": [');
    S.Add('    {');
    S.Add('      "type": "socks",');
    S.Add('      "listen": "127.0.0.1",');
    S.Add('      "listen_port": ' + SPortEdit.Text);
    S.Add('    },');
    S.Add('    {');
    S.Add('      "type": "http",');
    S.Add('      "listen": "127.0.0.1",');
    S.Add('      "listen_port": ' + HPortEdit.Text);
    S.Add('    }');
    S.Add('  ],');
    S.Add('');
    S.Add('  "outbounds": [');
    S.Add('    {');

    //Используем TCP или QUIC?
    if QUICBox.Checked then
      S.Add('      "type": "naive",')
    else
      S.Add('      "type": "http",');

    S.Add('      "tag": "proxy",');
    S.Add('      "server": "' + DomainEdit.Text + '",');
    S.Add('      "server_port": 443,');
    S.Add('      "username": "' + UserEdit.Text + '",');
    S.Add('      "password": "' + PasswordEdit.Text + '",');
    S.Add('      "tls": {');
    S.Add('        "enabled": true,');
    S.Add('        "server_name": "' + DomainEdit.Text + '"');
    S.Add('      }');
    S.Add('    },');
    S.Add('    {');
    S.Add('      "type": "direct",');
    S.Add('      "tag": "direct"');
    S.Add('    }');
    S.Add('  ],');
    S.Add('');
    S.Add('  "route": {');
    S.Add('    "rules": [');
    S.Add('      {');
    S.Add('        "domain_suffix": ["' + BypassBox.Text + '"],');
    S.Add('        "outbound": "direct"');
    S.Add('      }');
    S.Add('    ],');
    S.Add('    "final": "proxy",');
    S.Add('   "default_domain_resolver": "remote"');
    S.Add('  }');
    S.Add('}');

    S.SaveToFile(GetUserDir + '.config/naivegui/client.json');

  finally
    S.Free
  end;
end;

//Создаём конфиг Сервера
procedure TMainForm.CreateServerConfig;
var
  S: TStringList;
begin
  try
    S := TStringList.Create;

    S.Add('{');
    S.Add('   order forward_proxy before file_server');
    S.Add('}');

    S.Add('');
    S.Add(':443, ' + DomainEdit.Text + ' {');
    S.Add('   forward_proxy {');
    S.Add('                 basic_auth ' + UserEdit.Text + ' ' + PasswordEdit.Text);
    S.Add('                 hide_ip');
    S.Add('                 hide_via');
    S.Add('                 probe_resistance');
    S.Add('   }');
    S.Add('   file_server {');
    S.Add('                 root /var/www/html');
    S.Add('   }');
    S.Add('}');

    //Для /etc/caddy/Caddyfile на сервере
    S.SaveToFile(GetUserDir + '.config/naivegui/Caddyfile');
  finally
    S.Free;
  end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  bmp: TBitmap;
begin
  MainForm.Caption := Application.Title;

  // Устраняем баг иконки приложения
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf32bit;
    bmp.Assign(Image1.Picture.Graphic);
    Application.Icon.Assign(bmp);
  finally
    bmp.Free;
  end;

  if not DirectoryExists(GetUserDir + '.config/naivegui') then
    ForceDirectories(GetUserDir + '.config/naivegui');

  IniPropStorage1.IniFileName := GetUserDir + '.config/naivegui/naivegui.conf';
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  client_conf: string;
begin
  //Масштабирование для Plasma
  IniPropStorage1.Restore;

  client_conf := GetUserDir + '.config/naivegui/client.json';

  PassBtn.Width := PasswordEdit.Height;
  QRBtn.Width := CreateBtn.Height;

  if not FileExists(client_conf) then Exit;

  //Читаем параметры клиента
  if JsonReadString(client_conf, 'outbounds[0].type') = 'http' then
    QUICBox.Checked := False
  else
    QUICBox.Checked := True;

  DomainEdit.Text := JsonReadString(client_conf, 'outbounds[0].server');
  //  PortEdit.Text := JsonReadString(client_conf, 'outbounds[0].server_port');
  UserEdit.Text := JsonReadString(client_conf, 'outbounds[0].username');
  PasswordEdit.Text := JsonReadString(client_conf, 'outbounds[0].password');

  SPortEdit.Text := JsonReadString(client_conf, 'inbounds[0].listen_port');
  HPortEdit.Text := JsonReadString(client_conf, 'inbounds[1].listen_port');

  BypassBox.Text := JsonReadString(client_conf, 'dns.rules[0].domain_suffix[0]');

  //Запуск потока проверки состояния сервиса (active/inactive)
  ServiceState.Create(False);

  //Запуск поток непрерывного чтения лога
  ShowLogTRD.Create(False);
end;

procedure TMainForm.Label10Click(Sender: TObject);
begin
  OpenURL('https://www.speedtest.net/');
end;

procedure TMainForm.Label10MouseEnter(Sender: TObject);
begin
  Label10.Font.Color := clRed;  //подсветка при наведении
end;

procedure TMainForm.Label10MouseLeave(Sender: TObject);
begin
  Label10.Font.Color := clBlue;  //подсветка при наведении
end;

//Проверка страницы
procedure TMainForm.Label2Click(Sender: TObject);
begin
  OpenURL('https://' + DomainEdit.Text);
end;

procedure TMainForm.Label2MouseEnter(Sender: TObject);
begin
  Label2.Font.Color := clRed;  //подсветка при наведении
end;

procedure TMainForm.Label2MouseLeave(Sender: TObject);
begin
  Label2.Font.Color := clBlue;  //подсветка при наведении
end;

//Показать/скрыть пароль
procedure TMainForm.PassBtnClick(Sender: TObject);
begin
  if PasswordEdit.PasswordChar = Chr(0) then
    PasswordEdit.PasswordChar := #1
  else
    PasswordEdit.PasswordChar := Chr(0);
end;

//Создаём конфиги Клиента и Сервера
procedure TMainForm.CreateBtnClick(Sender: TObject);
begin
  //Не запускать, если поля пустые
  if (DomainEdit.Text = '') or (UserEdit.Text = '') or (PasswordEdit.Text = '') or
    (SPortEdit.Text = '') or (HPortEdit.Text = '') or (BypassBox.Text = '') then Exit;

  if FileExists(GetUserDir + '.config/naivegui/Caddyfile') then
    if MessageDlg(SConfigutarionFound, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

  //Клиент
  CreateClientConfig;
  //Сервер
  CreateServerConfig;

  //Выгружаем архив конфигураций Клиента и Сервера
  if SaveDialog1.Execute then
  begin
    if not AnsiEndsText('.tar.gz', SaveDialog1.FileName) then
    begin
      if SameText(ExtractFileExt(SaveDialog1.FileName), '.gz') then
        SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName, '.tar.gz')
      else
        SaveDialog1.FileName := SaveDialog1.FileName + '.tar.gz';
    end;

    //Создаём архив и выгружаем
    StartProcess(
      'cd ~/.config/naivegui; chmod 644 Caddyfile; tar -zcf naivegui_config.tar.gz Caddyfile client.json');

    CopyFile(GetUserDir + '.config/naivegui/naivegui_config.tar.gz',
      SaveDialog1.FileName, [cffOverwriteFile]);
  end;
end;

//Показать QR-код
procedure TMainForm.QRBtnClick(Sender: TObject);
var
  protocol: string;
begin
  if QRForm.Visible then Exit;

  //Не запускать, если поля пустые
  if (DomainEdit.Text = '') or (UserEdit.Text = '') or (PasswordEdit.Text = '') or
    (SPortEdit.Text = '') or (HPortEdit.Text = '') or (BypassBox.Text = '') then Exit;

  // if not FileExists(GetUserDir + '.config/naivegui/client.json') then Exit;

  //Определить протокол
  if QUICBox.Checked then protocol := 'naive+quic://'
  else
    protocol := 'naive+https://';

  QRForm.BarcodeQR1.Text := protocol + UserEdit.Text + ':' +
    PasswordEdit.Text + '@' + DomainEdit.Text + '#NaiveGUI';

  //Показать QR-код
  QRForm.Show;
end;

//Start + Enable
procedure TMainForm.StartBtnClick(Sender: TObject);
var
  S: string;
begin
  //Не запускать, если поля пустые
  if (DomainEdit.Text = '') or (UserEdit.Text = '') or (PasswordEdit.Text = '') or
    (SPortEdit.Text = '') or (HPortEdit.Text = '') or (BypassBox.Text = '') then Exit;

  //Не запускать ДО создания конфига Клиента и Сервера
  if not FileExists(GetUserDir + '.config/naivegui/client.json') then
  begin
    MessageDlg(SNoConfiguration, mtWarning, [mbOK], 0);
    Exit;
  end;

  //Пересоздаём конфиг клиента
  CreateClientConfig;

  //Пересоздаём пускач прокси
  CreateSWProxy;
  //Включаем прокси
  RunCommand('/bin/bash', ['-c', '~/.config/naivegui/swproxy.sh set'], S);

  RunCommand('systemctl', ['--user', 'restart', 'naivegui.service'], S, [poWaitOnExit]);
  RunCommand('systemctl', ['--user', 'enable', 'naivegui.service'], S, [poWaitOnExit]);
end;

//Stop + Disable
procedure TMainForm.StopBtnClick(Sender: TObject);
var
  S: string;
begin
  //Пересоздаём пускач прокси
  CreateSWProxy;
  //Отключаем системный прокси
  RunCommand('/bin/bash', ['-c', '~/.config/naivegui/swproxy.sh unset'], S);

  RunCommand('systemctl', ['--user', 'stop', 'naivegui.service'], S, [poWaitOnExit]);
  RunCommand('systemctl', ['--user', 'disable', 'naivegui.service'], S, [poWaitOnExit]);
end;

end.
