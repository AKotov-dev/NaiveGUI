unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, DefaultTranslator, IniPropStorage, LCLIntf, StrUtils,
  FileUtil, Process, fpjson, jsonparser, URIParser;

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
    Label1: TLabel;
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
    procedure CreateBtnClick(Sender: TObject);
    procedure QRBtnClick(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure CreateClientConfig;
    procedure CreateServerConfig;
    procedure CreateSWProxy;
    procedure StartProcess(command: string);
    procedure ParseNaiveConfig(const FilePath: string);

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

var
  USER_NAME, AUTH_PASS, PROTO, DOMAIN, naive_conf, xray_conf: string;

  {$R *.lfm}

  { TMainForm }

procedure TMainForm.ParseNaiveConfig(const FilePath: string);
var
  FileContent: TStringList;
  JsonDoc: TJSONData;
  JsonObj: TJSONObject;
  //  ListenStr: string;
  ProxyStr: string;
  Uri: TURI;
begin
  if not FileExists(FilePath) then Exit;

  FileContent := TStringList.Create;
  JsonDoc := nil;
  try
    // 1. Загружаем и парсим JSON
    FileContent.LoadFromFile(FilePath);
    JsonDoc := GetJSON(FileContent.Text);

    if JsonDoc.JSONType = jtObject then
    begin
      JsonObj := TJSONObject(JsonDoc);

      // 2. Читаем базовые строковые поля (безопасный метод с дефолтными значениями)
      // ListenStr := JsonObj.Get('listen', 'socks://127.0.0.1:11080');
      ProxyStr := JsonObj.Get('proxy', '');

      //   Writeln('Локальный адрес (Listen): ', ListenStr);

      // 3. Парсим сложную строку proxy (например, https://domain.com)
      if ProxyStr <> '' then
      begin
        Uri := ParseURI(ProxyStr);

     {   Writeln('Протокол: ', Uri.Protocol);
        Writeln('Пользователь: ', Uri.Username);
        Writeln('Пароль: ', Uri.Password);
        Writeln('Хост/Домен: ', Uri.Host);
        Writeln('Порт: ', Uri.Port); }

        PROTO := Uri.Protocol;
        USER_NAME := Uri.Username;
        AUTH_PASS := Uri.Password;
        DOMAIN := Uri.Host;

      end;

      // 4. Опционально: чтение других параметров, если они есть в конфиге
    {  if JsonObj.Find('concurrency') <> nil then
        Writeln('Потоки: ', JsonObj.Integers['concurrency']); }
    end;

  finally
    JsonDoc.Free;
    FileContent.Free;
  end;
end;

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

//Генерация случайных USER_NAME и AUTH_PASS
function GenerateString(ALength: integer): string;
const
  //Набор разрешенных символов без спецсимволов
  Chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
var
  i: integer;
begin
  SetLength(Result, ALength);
  for i := 1 to ALength do
  begin
    //Выбираем случайный символ из константы Chars
    Result[i] := Chars[Random(Length(Chars)) + 1];
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

    // ~/.naivegui/naive.json
    S.Add('{');
    S.Add('  "listen": "socks://127.0.0.1:51347",');

    if QuicBox.Checked then
      S.Add('  "proxy": "quic://' + USER_NAME + ':' + AUTH_PASS +
        '@' + Trim(DomainEdit.Text) + '"')
    else
      S.Add('  "proxy": "https://' + USER_NAME + ':' + AUTH_PASS +
        '@' + Trim(DomainEdit.Text) + '"');

    S.Add('}');

    S.SaveToFile(GetUserDir + '.config/naivegui/naive.json');

    // ~/.naivegui/xray.json
    S.Clear;

    S.Add('{');
    S.Add('"log": {');
    S.Add('  "loglevel": "info"');
    S.Add('},');
    S.Add('');

    S.Add('"dns": {');
    S.Add('  "servers": [');
    S.Add('    "1.1.1.1",');
    S.Add('    "8.8.8.8"');
    S.Add('  ]');
    S.Add('},');
    S.Add('');

    S.Add('"inbounds": [');
    S.Add('  {');
    S.Add('    "tag": "socks-in",');
    S.Add('    "listen": "127.0.0.1",');
    S.Add('    "port": ' + Trim(SPortEdit.Text) + ',');
    S.Add('    "protocol": "socks",');
    S.Add('    "settings": {');
    S.Add('      "udp": false');
    S.Add('    }');
    S.Add('  },');
    S.Add('');

    S.Add('  {');
    S.Add('    "tag": "http-in",');
    S.Add('    "listen": "127.0.0.1",');
    S.Add('    "port": ' + Trim(HPortEdit.Text) + ',');
    S.Add('    "protocol": "http"');
    S.Add('  }');
    S.Add('],');
    S.Add('');

    S.Add('"outbounds": [');
    S.Add('  {');
    S.Add('    "tag": "naive",');
    S.Add('    "protocol": "socks",');
    S.Add('    "settings": {');
    S.Add('      "servers": [');
    S.Add('        {');
    S.Add('          "address": "127.0.0.1",');
    // Порт связки xray >> naive
    S.Add('          "port": 51347');
    S.Add('        }');
    S.Add('      ]');
    S.Add('    }');
    S.Add('  },');
    S.Add('');

    S.Add('  {');
    S.Add('    "tag": "direct",');
    S.Add('    "protocol": "freedom"');
    S.Add('  }');
    S.Add('],');
    S.Add('');

    S.Add('"routing": {');
    S.Add('  "domainStrategy": "AsIs",');
    S.Add('');

    S.Add('  "rules": [');
    S.Add('    {');
    S.Add('      "type": "field",');
    S.Add('      "domain": [');

    //Поддержка зоны .рф
    if BypassBox.Text <> 'ru' then
      S.Add('        "' + Trim(BypassBox.Text) + '"')
    else
      S.Add('        "ru", "xn--p1ai"');

    S.Add('      ],');
    S.Add('      "outboundTag": "direct"');
    S.Add('    }');
    S.Add('  ]');
    S.Add('}');
    S.Add('}');

    S.SaveToFile(GetUserDir + '.config/naivegui/xray.json');

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
    S.Add(':443, ' + Trim(DomainEdit.Text) + ' {');
    S.Add('   forward_proxy {');
    S.Add('                 basic_auth ' + USER_NAME + ' ' + AUTH_PASS);
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

  // Инициализация генератора случайных чисел для USER_NAME и AUTH_PASS
  Randomize;

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
begin
  //Масштабирование для Plasma
  IniPropStorage1.Restore;

  naive_conf := GetUserDir + '.config/naivegui/naive.json';
  xray_conf := GetUserDir + '.config/naivegui/xray.json';

  //PassBtn.Width := PasswordEdit.Height;
  QRBtn.Width := CreateBtn.Height;

  //Запуск потока проверки состояния сервиса (active/inactive)
  ServiceState.Create(False);

  //Запуск поток непрерывного чтения лога
  ShowLogTRD.Create(False);

  if (not FileExists(naive_conf)) or (not FileExists(xray_conf)) then Exit;

  //Читаем параметры клиента
  ParseNaiveConfig(naive_conf);

  if PROTO = 'https' then
    QUICBox.Checked := False
  else
    QUICBox.Checked := True;

  DomainEdit.Text := DOMAIN;

  //Юзер и пароль уже считаны из ~/.naivegui/naive.json

  //Читаем порты из ~/.naivegui/xray.json
  SPortEdit.Text := JsonReadString(xray_conf, 'inbounds[0].port');
  HPortEdit.Text := JsonReadString(xray_conf, 'inbounds[1].port');

  //Достаём байпас (возвращается domain:ru - первый из массива)
 { BypassBox.Text := StringReplace(JsonReadString(xray_conf,
    'routing.rules[0].domain[0]'), 'domain:', '', [rfIgnoreCase]);}

  BypassBox.Text := JsonReadString(xray_conf, 'routing.rules[0].domain[0]');
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

//Создаём конфиги Клиента и Сервера
procedure TMainForm.CreateBtnClick(Sender: TObject);
begin
  //Не запускать, если поля пустые
  if (DomainEdit.Text = '') or (SPortEdit.Text = '') or (HPortEdit.Text = '') or
    (BypassBox.Text = '') then Exit;

  if FileExists(GetUserDir + '.config/naivegui/Caddyfile') then
    if MessageDlg(SConfigutarionFound, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

  // Генерация случайных USER_NAME и AUTH_PASS
  USER_NAME := GenerateString(10);
  AUTH_PASS := GenerateString(16);

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
      'cd ~/.config/naivegui; chmod 644 Caddyfile; tar -zcf naivegui_config.tar.gz Caddyfile naive.json xray.json');

    CopyFile(GetUserDir + '.config/naivegui/naivegui_config.tar.gz',
      SaveDialog1.FileName, [cffOverwriteFile]);
  end;
end;

//Показать QR-код
procedure TMainForm.QRBtnClick(Sender: TObject);
var
  protocol: string;
begin
  if QRForm.Visible then QRForm.BringToFront;

  //Не запускать, если поля пустые
  if (DomainEdit.Text = '') or (SPortEdit.Text = '') or (HPortEdit.Text = '') or
    (BypassBox.Text = '') then Exit;

  if (not FileExists(naive_conf)) or (not FileExists(xray_conf)) then Exit;

  //Определить протокол
  if QUICBox.Checked then protocol := 'naive+quic://'
  else
    protocol := 'naive+https://';

  QRForm.BarcodeQR1.Text := protocol + USER_NAME + ':' + AUTH_PASS +
    '@' + DomainEdit.Text + '#NaiveGUI';

  //Показать QR-код
  QRForm.Show;
end;

//Start + Enable
procedure TMainForm.StartBtnClick(Sender: TObject);
var
  S: string;
begin
  //Не запускать, если поля пустые
  if (DomainEdit.Text = '') or (SPortEdit.Text = '') or (HPortEdit.Text = '') or
    (BypassBox.Text = '') then Exit;

  //Не запускать ДО создания конфига Клиента и Сервера
  if (not FileExists(GetUserDir + '.config/naivegui/naive.json')) or
    (not FileExists(GetUserDir + '.config/naivegui/xray.json')) then
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

  RunCommand('systemctl', ['--user', 'restart', 'naive.service'], S, [poWaitOnExit]);
  RunCommand('systemctl', ['--user', 'enable', 'naive.service'], S, [poWaitOnExit]);
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

  RunCommand('systemctl', ['--user', 'stop', 'naive.service'], S, [poWaitOnExit]);
  RunCommand('systemctl', ['--user', 'disable', 'naive.service'], S, [poWaitOnExit]);
end;

end.
