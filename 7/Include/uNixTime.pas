unit uNixTime;
{//+-----------------------------------------------------------------+
    Set Of Functions To Convert UNIX Time <-> TDateTime
}//+-----------------------------------------------------------------+
interface
//+------------------------------------------------------------------+
uses Windows, SysUtils, StrUtils, DateUtils, Math;
//+------------------------------------------------------------------+
type TDtmType = (DTM_DATE, DTM_TIME, DTM_DATETIME, DTM_DATETIME_MS);
//+------------------------------------------------------------------+
function GetGmtOffsetSec:Int64;                                     // Returns GMT offset Seconds for Currnet User TimeZone
function GetGmtOffsetMin:Int64;                                     // Returns GMT offset Minutes for Currnet User TimeZone
function GetGmtOffsetHours:Int64;                                   // Returns GMT offset Hours for Currnet User TimeZone
//+------------------------------------------------------------------+
function UtcTimeCurrent:Int64;                                      // Returns UTC\GMT TimeCurrent
function GmtTimeCurrent:Int64;                                      // Returns UTC\GMT TimeCurrent
function UtcTimeCurrentMs:Int64;                                    // Returns UTC\GMT TimeCurrent with microseconds INT64
function GmtTimeCurrentMs:Int64;                                    // Returns UTC\GMT TimeCurrent with microseconds INT64
function GmtTimeCurrentMsDbl:Double;                                // Returns UTC\GMT TimeCurrent with microseconds Double
function UnixTimeCurrent:Int64;                                     // Returns Current Time In Unix formate
function UnixTimeCurrentMs:Int64;                                   // Returns Current Time with microseconds In Unix format
function UnixTimeCurrentMsDbl:Double;                               // Returns TimeCurrent UNIX Format with microseconds Double
//+------------------------------------------------------------------+
function DtmToUtcTime(Dtm:TDateTime):Int64;                         // Convert TDateTime To UTC Format
function DtmToUtcTimeMs(Dtm:TDateTime):Int64;                       // Convert TDateTime To UTC Format with microseconds INT64
function DtmToUtcTimeMsDbl(Dtm:TDateTime):Double;                   // Convert TDateTime To UTC Format with microseconds Double
function DtmToUnixTime(Dtm:TDateTime):Int64;                        // Convert TDateTime To UNIX Time Format
function DtmToUnixTimeMs(Dtm:TDateTime):Int64;                      // Convert TDateTime To UNIX Time Format with microseconds INT64
function DtmToUnixTimeMsDbl(Dtm:TDateTime):Double;                  // Convert TDateTime To UNIX Time Format with microseconds Double
//+------------------------------------------------------------------+
function UnixTimeToDtm(UTime:Int64):TDateTime;overload;             // Convert UNIX Time To Borland TDateTime
function UnixTimeToDtm(UTime:Cardinal):TDateTime;overload;          // Convert UNIX Time To Borland TDateTime
function UnixTimeMsToDtm(UTime:Int64):TDateTime;overload;           // Convert UNIX Miliseconds Time To Borland TDateTime
function UnixTimeMsToDtm(UTime:Double):TDateTime;overload;          // Convert UNIX Miliseconds Time To Borland TDateTime
//+------------------------------------------------------------------+
function GetMsOfCurrTime:Int64;                                     // Returns Miliseconds Of Current Time
function GetMsOfDateTime(Dtm:TDateTime):Int64;                      // Returns Miliseconds Of Gived TDateTime
function DaySecondsCount:Int64;                                     // Returns Count Of Seconds From Day Start
function DayMinutesCount:Int64;                                     // Returns Count Of Minutes From Day Start
function DayStartTime(Dtm:TDateTime=0):Int64;overload;              // Returns UNIX Time Of Start Of Day
function DayStartTime(UnixDtm:Int64=0):Int64;overload;              // Returns UNIX Time Of Start Of Day
//+------------------------------------------------------------------+
function IsNewUnixDay:Boolean;                                      // Returns true if The New day Starts between requests
function IsNewUtcDay:Boolean;                                       // Returns true if The New UTC day Starts between requests
function IsNewUTimeMinute:Boolean;                                  // Returns "True" If The New Minute Started
function LastUTimeMinute:Cardinal;                                  // Returns Last Minute Unix Start Time
function LastUTimeMinute64:Int64;                                   // Returns Last Minute Unix Start Time Int64
//+------------------------------------------------------------------+
function CurrTimeToStr(const format:TDtmType=DTM_DATETIME_MS):ShortString;                          // Returns Current Time As Formatted String
function FormatUnixTime(uTime:Int64; const format:TDtmType):ShortString;overload;      // Unix Time To Date Time String
function FormatUnixTime(uTime:Int64; const format:string='yyyy.mm.dd hh:nn:ss'):ShortString;overload;
function FormatUnixTimeMs(uTime:Int64; const format:TDtmType):ShortString;overload;
function FormatUnixTimeMs(uTimeMs:Int64; const format:string='yyyy.mm.dd hh:nn:ss.zzz'):ShortString;overload;
function FormatUnixTimeMs(uTimeMs:Double; const format:string='yyyy.mm.dd hh:nn:ss.zzz'):ShortString;overload;
//+------------------------------------------------------------------+
function FileTimeToDateTime(FileTime: TFileTime): TDateTime;	    // Преобразовывает время в формате файлового времени в борланд формат
function FileGetUnixTime(path:string):LongInt;                      // Возвращает время создания\измения файла в юникс веремени
//+------------------------------------------------------------------+
var GPrevTime   : Int64=0;
    GPrevDay    : Int64=0;
    GPrevUtcDay : Int64=0;
    GmtOffset   : Int64=0;
    GmtOffsetSet: Boolean=False;
//+------------------------------------------------------------------+
implementation
//+------------------------------------------------------------------+
//  Save GMT offset at global variable when first request to function
//+------------------------------------------------------------------+
procedure SetGmtOffset;var tmzn:TTimeZoneInformation;
begin
    if( GmtOffsetSet )then Exit;
    GetTimeZoneInformation(tmzn);
    GmtOffset:=(tmzn.Bias*60);
    GmtOffsetSet:=True;
end;
//+------------------------------------------------------------------+
function GetGmtOffsetSec:Int64;
begin
    Result:=GmtOffset;
    if( GmtOffsetSet )then Exit;
    SetGmtOffset;
    Result:=GmtOffset;
end;
//+------------------------------------------------------------------+
function GetGmtOffsetMin:Int64;begin Result:=Trunc(GetGmtOffsetSec/60)end;
//+------------------------------------------------------------------+
function GetGmtOffsetHours:Int64;begin Result:=Trunc(GetGmtOffsetSec/3600)end;
//+------------------------------------------------------------------+
function UnixTimeCurrent:Int64;begin Result:=Trunc((Now-25569.0)*86400);end;
//+------------------------------------------------------------------+
function UnixTimeCurrentMs:Int64;begin Result:=Trunc((Now-25569.0)*86400*1000);end;
//+------------------------------------------------------------------+
function UnixTimeCurrentMsDbl:Double;begin Result:=(Now-25569.0)*86400;end;
//+------------------------------------------------------------------+
function DtmToUnixTime(Dtm:TDateTime):Int64;begin Result:=Trunc((Dtm-25569.0)*86400);end;
//+------------------------------------------------------------------+
function DtmToUnixTimeMs(Dtm:TDateTime):Int64;begin Result:=Trunc((Dtm-25569.0)*86400*1000);end;
//+------------------------------------------------------------------+
function DtmToUnixTimeMsDbl(Dtm:TDateTime):Double;begin Result:=(Dtm-25569.0)*86400;end;
//+------------------------------------------------------------------+
function UtcTimeCurrent:Int64;begin SetGmtOffset;Result:=Trunc((Now-25569.0)*86400)+GmtOffset;end;
//+------------------------------------------------------------------+
function GmtTimeCurrent:Int64;begin Result:=UtcTimeCurrent;end;
//+------------------------------------------------------------------+
function DtmToUtcTime(Dtm:TDateTime):Int64;begin SetGmtOffset;Result:=Trunc((Dtm-25569.0)*86400)+GmtOffset;end;
//+------------------------------------------------------------------+
function UtcTimeCurrentMs:Int64;begin SetGmtOffset;Result:=Trunc((Now-25569.0)*86400*1000)+GmtOffset;end;
//+------------------------------------------------------------------+
function GmtTimeCurrentMsDbl:Double;begin SetGmtOffset;Result:=(Now-25569.0)*86400+GmtOffset;end;
//+------------------------------------------------------------------+
function GetMsOfCurrTime:Int64;begin Result:=Trunc(Frac((Now-25569.0)*86400)*1000);end;
//+------------------------------------------------------------------+
function GetMsOfDateTime(Dtm:TDateTime):Int64;begin Result:=Trunc(Frac((Dtm-25569.0)*86400)*1000);end;
//+------------------------------------------------------------------+
function GmtTimeCurrentMs:Int64;begin Result:=UtcTimeCurrentMs;end;
//+------------------------------------------------------------------+
function DtmToUtcTimeMs(Dtm:TDateTime):Int64;begin SetGmtOffset;Result:=Trunc((Dtm-25569.0)*86400*1000)+GmtOffset;end;
//+------------------------------------------------------------------+
function DtmToUtcTimeMsDbl(Dtm:TDateTime):Double;begin SetGmtOffset;Result:=(Dtm-25569.0)*86400+GmtOffset;end;
//+------------------------------------------------------------------+
function UnixTimeToDtm(UTime:Int64):TDateTime;begin Result := (UTime / 86400) + 25569.0;end;
//+------------------------------------------------------------------+
function UnixTimeToDtm(UTime:Cardinal):TDateTime;begin Result := (UTime / 86400) + 25569.0;end;
//+------------------------------------------------------------------+
function UnixTimeMsToDtm(UTime:Int64):TDateTime;begin Result := (UTime / (86400*1000)) + 25569.0;end;
//+------------------------------------------------------------------+
function UnixTimeMsToDtm(UTime:Double):TDateTime;begin Result := (UTime / 86400) + 25569.0;end;
//+------------------------------------------------------------------+
function FormatUnixTime(uTime:Int64; const format:string='yyyy.mm.dd hh:nn:ss'):ShortString; begin Result:=FormatDateTime(format,UnixTimeToDtm(uTime));end;
//+------------------------------------------------------------------+
function FormatUnixTimeMs(uTimeMs:Int64; const format:string='yyyy.mm.dd hh:nn:ss.zzz'):ShortString;begin Result:=FormatDateTime(format,UnixTimeMsToDtm(uTimeMs));end;
//+------------------------------------------------------------------+
function FormatUnixTimeMs(uTimeMs:Double; const format:string='yyyy.mm.dd hh:nn:ss.zzz'):ShortString;begin Result:=FormatDateTime(format,UnixTimeMsToDtm(uTimeMs));end;
//+------------------------------------------------------------------+
function FormatUnixTime(uTime:Int64; const format:TDtmType):ShortString;overload;
begin
    case format of
        DTM_DATETIME : Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss',UnixTimeToDtm(uTime));
        DTM_DATE : Result:=FormatDateTime('yyyy.mm.dd',UnixTimeToDtm(uTime));
        DTM_TIME : Result:=FormatDateTime('hh:nn:ss',UnixTimeToDtm(uTime));
    else
        Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss',UnixTimeToDtm(uTime));
    end;
end;
//+------------------------------------------------------------------+
function FormatUnixTimeMs(uTime:Int64; const format:TDtmType):ShortString;overload;
begin
    case format of
        DTM_DATETIME : Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss',UnixTimeToDtm(uTime));
        DTM_DATETIME_MS : Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss.zzzz',UnixTimeMsToDtm(uTime));
        DTM_DATE : Result:=FormatDateTime('yyyy.mm.dd',UnixTimeToDtm(uTime));
        DTM_TIME : Result:=FormatDateTime('hh:nn:ss',UnixTimeToDtm(uTime));
    else
        Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss',UnixTimeToDtm(uTime));
    end;
end;
//+------------------------------------------------------------------+
function CurrTimeToStr(const format:TDtmType=DTM_DATETIME_MS):ShortString;
begin
    case format of
        DTM_DATETIME_MS : Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss.zzz',Now);
        DTM_DATETIME : Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss',Now);
        DTM_DATE : Result:=FormatDateTime('yyyy.mm.dd',Now);
        DTM_TIME : Result:=FormatDateTime('hh:nn:ss',Now);
    else
        Result:=FormatDateTime('yyyy.mm.dd hh:nn:ss',Now);
    end;
end;
//+------------------------------------------------------------------+
function IsNewUnixDay:Boolean;var cTime,tDay:Int64;
begin
    Result:=False;
    cTime := Trunc((Now-25569.0)*86400);
    tDay  := cTime div 86400;
    if( GPrevDay = 0 )then begin
        GPrevDay := tDay;
        Exit;
    end;
    if( GPrevDay = tDay )then Exit;
    GPrevDay := tDay;
    Result:=True;
end;
//+------------------------------------------------------------------+
function IsNewUtcDay:Boolean;var cTime,tday:Int64;
begin
    SetGmtOffset;
    Result:=False;
    cTime := Trunc((Now-25569.0)*86400)+GmtOffset;
    tDay  := cTime div 86400;
    if( GPrevUtcDay = 0 )then begin
        GPrevUtcDay := tDay;
        Exit;
    end;
    if( GPrevUtcDay = tDay )then Exit;
    GPrevUtcDay := tDay;
    Result:=True;
end;
//+------------------------------------------------------------------+
function IsNewUTimeMinute:Boolean;var cTime:Int64;
begin
    Result:=False;
    cTime := Trunc((Now-25569.0)*86400);
    if( cTime mod 60 = 0 )and( GPrevTime <> cTime )then begin
        GPrevTime := cTime;
        Result:=True;
    end;
end;
//+------------------------------------------------------------------+
function LastUTimeMinute:Cardinal;var cTime:Cardinal;
begin
    cTime := Trunc((Now-25569.0)*86400);
    if( cTime mod 60 = 0 )then begin
        Result:=cTime-60;
    end else begin
        Result:=cTime-(cTime mod 60);
    end;
end;
//+------------------------------------------------------------------+
function LastUTimeMinute64:Int64;var cTime:Cardinal;
begin
    cTime := Trunc((Now-25569.0)*86400);
    if( cTime mod 60 = 0 )then begin
        Result:=cTime-60;
    end else begin
        Result:=cTime-(cTime mod 60);
    end;
end;
//+------------------------------------------------------------------+
function DayStartTime(Dtm:TDateTime=0):Int64;var cTime:Int64;
begin
    if( Dtm = 0 )then begin
        cTime := Trunc((Now-25569.0)*86400);
    end else begin
        cTime := Trunc((Dtm-25569.0)*86400);
    end;
    Result:=cTime-(cTime mod 86400);
end;
//+------------------------------------------------------------------+
function DayStartTime(UnixDtm:Int64=0):Int64;var cTime:Int64;
begin
    if( UnixDtm = 0 )then begin
        cTime:=UtcTimeCurrent;
        Result:=cTime-(cTime mod 86400);
    end else begin
        Result:=UnixDtm-(UnixDtm mod 86400);
    end;
end;
//+------------------------------------------------------------------+
function DaySecondsCount:Int64;begin Result:= Trunc((Now-25569.0)*86400) mod 86400;end;
//+------------------------------------------------------------------+
function DayMinutesCount:Int64;begin Result:= Trunc((Now-25569.0)*86400) mod 1440;end;
//+------------------------------------------------------------------+
function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
var
ModifiedTime: TFileTime;
SystemTime: TSystemTime;
begin
	Result := 0;
	if (FileTime.dwLowDateTime = 0) and (FileTime.dwHighDateTime = 0) then Exit;
	try
		FileTimeToLocalFileTime(FileTime, ModifiedTime);
		FileTimeToSystemTime(ModifiedTime, SystemTime);
		Result := SystemTimeToDateTime(SystemTime);
	except
		Result := 0;  // Something to return in case of error
	end;
end;
//+------------------------------------------------------------------+
function FileGetUnixTime(path:string):LongInt;
var sr:TSearchRec;
begin
    Result:=-1;
    if( FindFirst(path,faAnyFile,sr) = 0 )then begin
        Result:=DtmToUnixTime(FileDateToDateTime(sr.Time));
        FindClose(sr);
    end;
end;
//+------------------------------------------------------------------+
end.
