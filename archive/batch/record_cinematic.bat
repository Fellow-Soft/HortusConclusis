@echo off
echo Starting Hortus Conclusus Cinematic Recording...
echo.
echo This will launch Godot and record the cinematic sequence to an MP4 file.
echo The recording will take approximately 2 minutes to complete.
echo.
echo Press any key to continue or Ctrl+C to cancel.
pause > nul

echo.
echo Launching Godot with the recording scene...
echo.

REM Find Godot executable - try common locations
set GODOT_PATH=""

REM Check Program Files location
if exist "C:\Program Files\Godot\Godot_v4.3-stable_win64.exe" (
    set GODOT_PATH="C:\Program Files\Godot\Godot_v4.3-stable_win64.exe"
    goto found_godot
)

REM Check Program Files (x86) location
if exist "C:\Program Files (x86)\Godot\Godot_v4.3-stable_win64.exe" (
    set GODOT_PATH="C:\Program Files (x86)\Godot\Godot_v4.3-stable_win64.exe"
    goto found_godot
)

REM Check Desktop location
if exist "%USERPROFILE%\Desktop\Godot_v4.3-stable_win64.exe" (
    set GODOT_PATH="%USERPROFILE%\Desktop\Godot_v4.3-stable_win64.exe"
    goto found_godot
)

REM Check Downloads location
if exist "%USERPROFILE%\Downloads\Godot_v4.3-stable_win64.exe" (
    set GODOT_PATH="%USERPROFILE%\Downloads\Godot_v4.3-stable_win64.exe"
    goto found_godot
)

REM Check Documents location
if exist "%USERPROFILE%\Documents\Godot\Godot_v4.3-stable_win64.exe" (
    set GODOT_PATH="%USERPROFILE%\Documents\Godot\Godot_v4.3-stable_win64.exe"
    goto found_godot
)

REM If we get here, we couldn't find Godot
echo ERROR: Could not find Godot executable.
echo Please enter the full path to your Godot executable:
set /p GODOT_PATH=

:found_godot
echo Found Godot at: %GODOT_PATH%
echo.

REM Launch Godot with the recording scene
%GODOT_PATH% --path "%~dp0" --scene "res://scenes/hortus_conclusus_cinematic_recording.tscn"

echo.
echo Recording complete!
echo The MP4 file is saved in your user data directory.
echo Location: %APPDATA%\Godot\app_userdata\Hortus Conclusis\cinematic_recording.mp4
echo.
echo Press any key to exit.
pause > nul
