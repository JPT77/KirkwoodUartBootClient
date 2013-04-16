program kirkwooduartboot;

// (C) JPT 2013, licenced under GPLv2

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, kirkwooduartboot_serial;

type

  { TSerialApp }

  TSerialApp = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure WriteHelp; virtual;
  end;

{ TSerialApp }

procedure TSerialApp.DoRun;
var
  ErrorMsg: String;
  Boot: TSerial;
  baud: integer = 115200;
  device: String = '/dev/ttyUSB0';
  mode: byte;

begin
  // quick check parameters
  ErrorMsg:=CheckOptions('hb::d::m:',['help','baud','device','mode']);
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    WriteHelp;
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;
  if HasOption('m','mode') then begin
    mode:=StrToInt('$'+(GetOptionValue('m','mode')));
  end else begin
    Writeln('Mode parameter is missing.');
    WriteHelp;
    Terminate;
    Exit;
  end;
  if HasOption('b','baud') then begin
     baud:=StrToInt(GetOptionValue('b','baud'));
  end;
  if HasOption('d','device') then begin
     device:=GetOptionValue('d','device');
  end;

  Boot:=TSerial.Create;
  Boot.Run(device, baud, mode);

  Terminate;
end;

constructor TSerialApp.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

procedure TSerialApp.WriteHelp;
begin
  writeln('Usage: ',ExeName,' -h -m <mode> -b <baudrate> -d <device>');
  writeln(#9'-h --help'#9'Print this help.');
  writeln('*'#9'-m --mode <m>'#9'Boot into mode bb (boot from serial via xmodem) or dd (debug console).');
  writeln(#9'-b --baud'#9'Baudrate. Default 115200.');
  writeln(#9'-d --device'#9'Device, eg /dev/ttyS0. Default /dev/ttyUSB0');
  writeln('* - Parameter is mandatory.');
end;

var
  Application: TSerialApp;

{$R *.res}

begin
  Application:=TSerialApp.Create(nil);
  Application.Run;
  Application.Free;
end.

