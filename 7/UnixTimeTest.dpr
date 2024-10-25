program UnixTimeTest;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uNixTime in 'Include\uNixTime.pas';

begin
    Writeln('UnixTimeCurrent = ',UnixTimeCurrent);
    Writeln('UnixTimeCurrentMs = ',UnixTimeCurrentMs);
    Writeln(FormatUnixTimeMs(UnixTimeCurrentMs,DTM_DATETIME_MS));
    Writeln(CurrTimeToStr);

    Readln;
end.
