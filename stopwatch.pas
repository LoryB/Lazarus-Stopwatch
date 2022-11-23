{*****************************************************************}
{                                                                 }
{     High frequency stop watch implementation for Delphi/FPC     }
{           Enhanced elapsed properties while running             }
{                                                                 }
{             Copyright (c) 2012 by Inoussa OUEDRAOGO             }
{                Enhanced (c) 2022 by Lorenzo Bardi               }
{                                                                 }
{      This source code is distributed under the Library GNU      }
{     General Public License with the following modification:     }
{     - object files and libraries linked into an application     }
{              may be distributed without source code.            }
{                                                                 }
{ This program is distributed in the hope that it will be useful, } 
{ but WITHOUT ANY WARRANTY; without even the implied warranty of  }
{     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.        }
{                                                                 }
{*****************************************************************}

{$IFDEF FPC}
  {$mode objfpc}{$H+}
  {$modeswitch advancedrecords}
{$ENDIF}

{$IFDEF MSWINDOWS}
    {$IFNDEF WINDOWS}
        {$DEFINE WINDOWS}
    {$ENDIF WINDOWS}
{$ENDIF MSWINDOWS}

unit stopwatch;

interface
uses
  SysUtils
  {$IFDEF LINUX}
  ,unixtype, linux
  {$ENDIF LINUX}
  ;

type

  { TStopWatch }

  TStopWatch = record
  private
    const
      C_THOUSAND = 1000;
      C_MILLION  = C_THOUSAND * C_THOUSAND;
      C_BILLION  = C_THOUSAND * C_THOUSAND * C_THOUSAND;
      TicksPerNanoSecond   = 100;
      TicksPerMilliSecond  =  10000;
      TicksPerSecond       = C_BILLION div 100;
    Type
      TBaseMeasure =
        {$IFDEF WINDOWS}
           Int64;
        {$ENDIF WINDOWS}
      {$IFDEF LINUX}
           TTimeSpec;
      {$ENDIF LINUX}
  strict private
    class var FFrequency : Int64;
    class var FIsHighResolution : Boolean;
  strict private
    FElapsed : Int64;
    FRunning : Boolean;
    FStartPosition : TBaseMeasure;
    FUpdatePosition: TBaseMeasure;
  strict private
    procedure CheckInitialization();inline;
    procedure UpdateElapsed();
    function GetElapsedMilliseconds: Int64;
    function GetElapsedTicks: Int64;
  public
    class function Create() : TStopWatch;static;
    class function StartNew() : TStopWatch;static;
    class property Frequency : Int64 read FFrequency;
    class property IsHighResolution : Boolean read FIsHighResolution;
    procedure Reset();
    procedure Start();
    procedure Stop();
    property ElapsedMilliseconds : Int64 read GetElapsedMilliseconds;
    property ElapsedTicks : Int64 read GetElapsedTicks;
    property IsRunning : Boolean read FRunning;
  end;

resourcestring
  sStopWatchNotInitialized = 'The StopWatch is not initialized.';

implementation
{$IFDEF WINDOWS}
uses
  Windows;
{$ENDIF WINDOWS}

{ TStopWatch }

class function TStopWatch.Create(): TStopWatch;
{$IFDEF LINUX}
var
  r : TBaseMeasure;
{$ENDIF LINUX}
begin
  if (FFrequency = 0) then begin
{$IFDEF WINDOWS}
    FIsHighResolution := QueryPerformanceFrequency(FFrequency);
{$ENDIF WINDOWS}
{$IFDEF LINUX}
    FIsHighResolution := (clock_getres(CLOCK_MONOTONIC,@r) = 0);
    FIsHighResolution := FIsHighResolution and (r.tv_nsec <> 0);
    if (r.tv_nsec <> 0) then
      FFrequency := C_BILLION div r.tv_nsec;
{$ENDIF LINUX}
  end;
  FillChar(Result, SizeOf(Result), 0);
end;

class function TStopWatch.StartNew() : TStopWatch;
begin
  Result := TStopWatch.Create();
  Result.Start();
end;

procedure TStopWatch.CheckInitialization();
begin
  if (FFrequency = 0) then
    raise Exception.Create(sStopWatchNotInitialized);
end;

procedure TStopWatch.UpdateElapsed;
var locEnd : TBaseMeasure;
    s, n : Int64;
begin
  {$IFDEF WINDOWS}
  QueryPerformanceCounter(locEnd);
  FElapsed := FElapsed + (UInt64(locEnd) - UInt64(FUpdatePosition));
  {$ENDIF WINDOWS}
  {$IFDEF LINUX}
    clock_gettime(CLOCK_MONOTONIC,@locEnd);
    if (locEnd.tv_nsec < FUpdatePosition.tv_nsec) then begin
      s := locEnd.tv_sec - FUpdatePosition.tv_sec - 1;
      n := C_BILLION + locEnd.tv_nsec - FUpdatePosition.tv_nsec;
    end else begin
      s := locEnd.tv_sec - FUpdatePosition.tv_sec;
      n := locEnd.tv_nsec - FUpdatePosition.tv_nsec;
    end;
    FElapsed := FElapsed + (s * C_BILLION) + n;
  {$ENDIF LINUX}
  Move(locEnd, FUpdatePosition, SizeOf(TBaseMeasure));
end;

function TStopWatch.GetElapsedMilliseconds: Int64;
begin
  if FRunning then
    UpdateElapsed();
  {$IFDEF WINDOWS}
    Result := ElapsedTicks * TicksPerMilliSecond;
  {$ENDIF WINDOWS}
  {$IFDEF LINUX}
    Result := FElapsed div C_MILLION;
  {$ENDIF LINUX}
end;

function TStopWatch.GetElapsedTicks: Int64;
begin
  CheckInitialization();
  if FRunning then
    UpdateElapsed();
{$IFDEF WINDOWS}
  Result := (FElapsed * TicksPerSecond) div FFrequency;
{$ENDIF WINDOWS}
{$IFDEF LINUX}
  Result := FElapsed div TicksPerNanoSecond;
{$ENDIF LINUX}
end;

procedure TStopWatch.Reset();
begin
  Stop();
  FElapsed := 0;
  FillChar(FStartPosition, SizeOf(FStartPosition), 0);
  FillChar(FUpdatePosition, SizeOf(FUpdatePosition), 0);
end;

procedure TStopWatch.Start();
begin
  if FRunning then
    Exit;
  FRunning := True;
{$IFDEF WINDOWS}
  QueryPerformanceCounter(FStartPosition);
{$ENDIF WINDOWS}
{$IFDEF LINUX}
  clock_gettime(CLOCK_MONOTONIC,@FStartPosition);
{$ENDIF LINUX}
  Move(FStartPosition, FUpdatePosition, SizeOf(TBaseMeasure));
end;

procedure TStopWatch.Stop();
begin
  if not FRunning then
    Exit;
  FRunning := False;
  UpdateElapsed();
end;

end.
