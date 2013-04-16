unit kirkwooduartboot_serial;

// (C) JPT 2013, licenced under GPLv2

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Synaser;

type
    TSerial = class
    private
    protected
      function RunExternalProgram(const Name: String; const Filename: String; const Device: String):integer;
      function Connect(const Device: String; const Baud: integer; const Databits:byte; const Parity:char;
               const Stopbits: byte; const SoftwareFlow: boolean; const HardwareFlow: boolean): TBlockSerial;
    public
      function Run(const Device: String; const Baud: Integer; const Mode: byte):integer;
    end;

implementation

// TODO use StrToInt64 instead
Function HexToStr(s: String): String;
Var i: Integer;
Begin
  Result:=''; i:=1;
  While i<Length(s) Do Begin
    Result:=Result+Chr(StrToIntDef('$'+Copy(s,i,2),0));
    Inc(i,2);
  End;
End;

{ Writes a byte as char or hex, depending if it is a readable char or a control code. }
procedure WriteByte(b: byte);
begin
  case byte(b) of
    // 0..$19:
    $20..$7E: Write(char(b));
    $0D,$0A: Write(char(b));
    // $7F..$FF:
    else Write('0x',IntToHex(b,2),' ');
  end;
end;

{ Checks the last result of a serial command. returns true if successful. Prints Status. }
function CheckSerialErrorCode(Serial: TBlockSerial): boolean;
begin
  result:=(Serial.LastError = sOk);
  if result
    then Writeln('OK')
    else Writeln('Error ',Serial.LastError, ' = ', Serial.GetErrorDesc(Serial.LastError));
end;


function TSerial.Connect(const Device: String; const Baud: integer; const Databits:byte; const Parity:char;
         const Stopbits: byte; const SoftwareFlow: boolean; const HardwareFlow: boolean): TBlockSerial;
const
  loopdelay = 100;
var
  i, step: integer;
  b: byte;
begin
  Write('Waiting for ', Device, ': ');
  i:= 120000 div loopdelay; // 2 minutes
  step := 1000 div loopdelay;  // so we get a dot every second
  while not FileExists(Device) do begin
    if i mod step = 0 then Write('.');
    dec(i);
    Sleep(loopdelay);
    if i <= 0 then begin
      Writeln('Timeout.');
      result:=nil;
      exit;
    end;
  end;
  Writeln('OK');
  result:=TBlockSerial.Create;
  i:=0;
  Write('Open ', Device, ': ');
  while true do begin
    result.Connect(Device);
    if not CheckSerialErrorCode(result) then
      case result.LastError of
        ErrAlreadyOwned: begin
          Writeln('If this is in error, delete ', result.LockfileName);
          result.Free;
          result:=nil;
          exit; // function
        end;
        13: begin // 13: permission denied
          inc(i);
          if i > 2 then begin
            Writeln('Giving up. Check your permissions, ie. are you member of the dialout group?');
            result.Free;
            result:=nil;
            exit; // function
          end;
          Write('Retrying: ');
          Sleep(500);
        end;
     end else begin
       break; // while loop
     end;
  end;

  Write('Set Parameters to ', Baud, ', ', Databits,', ',Parity,', ',Stopbits,', SoftwareFlow: ', SoftwareFlow, ', HardwareFlow: ', HardwareFlow, ': ');
  result.Config(Baud, Databits, Parity, Stopbits, SoftwareFlow, HardwareFlow);
  if not CheckSerialErrorCode(result) then exit;

  Write('Clear Recieve Buffer: ');
  while result.CanReadEx(0) do begin
    b:=result.RecvByte(10);
    if not b = 0 then WriteByte(b);
  end;
  Writeln('OK');
end;


function TSerial.Run(const Device: String; const Baud: Integer; const Mode: byte):integer;
const
  // TODO use StrToInt64 instead
  commandcode = '11223344556677';
//  x = $11223344556677;
  loopdelay = 100;
  bootstrap : String[9] = 'Bootstrap';
  XmodemUpload = './xmodem-upload.sh';
  TerminalProgram = './terminal-program.sh';
var
  Serial:TBlockSerial;
  i, step, idx: integer;
  b, bLast: byte;
  ready: boolean;

begin
  Serial:=nil;
  try
    Serial:=Connect(Device, Baud, 8, 'N', 1, false, false);
    if Serial = nil then exit(-1);

    Write('Sending Command Code ',IntToHex(Mode,2),commandcode,': ');
    i:=120000 div loopdelay; // 2 minutes
    step:=1000 div loopdelay; // so we get a dot every second
    ready:=false;
    idx:=1;
    b:=0;
    repeat
      Serial.SendString(char(Mode));
      Serial.SendString(HexToStr(commandcode));
      if not Serial.LastError = sOk then begin
        Writeln('Error ',Serial.LastError, ' = ', Serial.GetErrorDesc(Serial.LastError));
        exit(-2);
      end;

      if i mod step = 0 then Write('.');
      dec(i);

      Sleep(loopdelay);

      while Serial.CanReadEx(0) do begin
        i:=(((i div step) + 1)  * step) - 1;  // reset I so we don't get a dot into the text output.
        bLast:=b;
        b:=Serial.RecvByte(10);
        case mode of
          $bb: begin
            ready:=(bLast=$15) and (b=$15); // recieved $15 XModem NACK: initiate transfer
            if not (b in [$00,$FF,$bb,$dd,$11]) and not (b = bLast+$11) then begin
              WriteByte(b);
            end;
          end;
          $dd: begin
            if idx > length(bootstrap) then begin
              WriteByte(b);
              for idx:=idx to idx+4 do begin
                b:=Serial.RecvByte(10);
                WriteByte(b);
              end;
              ready:= true;
            end else begin
              if (char(b) = bootstrap[idx]) then begin
                inc(idx);
              end else begin
                idx:=1;
              end;
              if (idx > 2) or not (b in [$00,$FF,$bb,$dd,$11]) and not (b = bLast+$11) then begin
                WriteByte(b);
              end;
            end;
          end;
        end;
      end;

      if i <= 0 then begin
        Writeln('Timeout');
        exit(-3);
      end;
    until ready;
    case mode of
      $bb: begin
        Writeln('OK. Device is requesting Xmodem transfer now.');
      end;
      $dd: begin
        Writeln(^j'OK. Device is in Boostrap-Debug-Console mode now. Open your terminal and have fun!');
      end;
    end;
    Writeln('Last serial error: ',Serial.LastError, ' = ', Serial.GetErrorDesc(Serial.LastError));
    Writeln('Last byte received: ', IntToHex(b,2));

  finally
    if not (Serial = nil) then begin
      Write('Close ', Device,': ');
      Serial.CloseSocket;
      CheckSerialErrorCode(serial);
    end;
    Serial.Free;
  end;



  if (mode = $bb) then begin
    case RunExternalProgram('Xmodem Upload', XmodemUpload, Device) of
      0:; // continue
      -1: begin
          Writeln('Create it with content like "sx -vv -b [u-boot] <$1 >$1" and make it executable. Don''t forget Shebang: #!/bin/sh');
          exit(-4);
      end;
      else exit(-6);
    end;
    case RunExternalProgram('Terminal program', TerminalProgram, Device) of
      0:; // continue
      -1: begin
          Writeln('Create a shell script calling your terminal app and make it executable. Don''t forget Shebang: #!/bin/sh');
          exit(-6);
      end;
      else exit(-7);
    end;
  end;
end;

function TSerial.RunExternalProgram(const Name: String; const Filename: String; const Device: String):integer;
var
  i: integer;
begin
  if not FileExists(Filename) then begin
    Writeln('Starting ', Name, ': ', Filename, ' does not exist.');
    exit(-1);
  end;
  Writeln('Starting ', Name, ': ');
  try
    i:=SysUtils.ExecuteProcess(Filename, [Device], []);
    if i=0 then begin
      Writeln(Name, ' successfully closed.')
    end else begin
      Writeln(Name, ' Errorcode: ', i);
      exit(-2);
    end;
  except
    on eos: EOSError do begin
        Writeln(Name, ' Error ',eos.ErrorCode, ' = ', eos.Message);
    end;
    on ex: Exception do begin
        Writeln(Name, ' Error ',ex.ClassName, ': ', ex.Message);
    end;
  end;
end;


end.

