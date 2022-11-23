# Lazarus-Stopwatch

High frequency stop watch implementation for Lazarus

## Description

**Works with Lazarus IDE for Windows and Linux targets**

Use TStopwatch to obtain access to high frequency timers that can be used to monitor the time spent performing some operations.
TStopwatch uses operating system-dependent functionality to gain access to high frequency timers, if available; otherwise, the usual timers are used.

TStopwatch is not a class but still requires explicit initialization. Call the StartNew or Create method to initialize a TStopwatch value.

## Features

Enhanced version by Lorenzo Bardi (LoryB) branched from master written by Inoussa OUEDRAOGO in 2012.<br>
This version enhances elapsed properties allowing them to work properly while stopwatch is running.

## Installation

Just import [stopwatch.pas](stopwatch.pas) in your project or in the IDE library

## Properties

- Use StartNew to initialize and return a new TStopwatch value. StartNew sets the newly created stopwatch to "started".
- Use Create to initialize and return a new TStopwatch value. Create sets the newly created stopwatch to "stopped".
- Call Start to start a stopped stopwatch. If the stopwatch was previously started, Start simply returns.
- Call Stop to stop a started stopwatch. If the stopwatch is already stopped, Stop simply returns.<br>
With Start & Stop properties, the total elapsed time is cumulated with the new time span.
- Call Reset to reset the stopwatch. Reset clears all the time intervals measured before and sets the stopwatch into a stopped state.
- Call ElapsedMilliseconds to get the elapsed milliseconds from the start timestamp.
- Call ElapsedTicks to get the elapsed ticks from the start timestamp.
- Call IsRunning to check if stopwatch has been set to "started".
- Call IsHighResolution to check if stopwatch is running in high resolution.
- Call Frequency to get stopwatch frequency calculated during initialization.
