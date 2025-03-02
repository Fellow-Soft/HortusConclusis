@echo off
echo Starting Hortus Conclusus Cinematic Recording...
echo.
echo This will launch Godot and record the cinematic sequence as a series of PNG images.
echo The recording will take approximately 2 minutes to complete.
echo.

REM Set the path to Godot executable - EDIT THIS LINE to match your Godot installation
set GODOT_PATH="C:\Users\joshu\Godot\godot.exe"

echo Checking if Godot exists at: %GODOT_PATH%
if exist %GODOT_PATH% (
    echo Godot executable found!
) else (
    echo ERROR: Godot executable not found at %GODOT_PATH%
    echo Please edit this batch file and set the correct path to your Godot executable.
    echo.
    echo Press any key to exit.
    pause > nul
    exit /b
)

echo.
echo Current directory: %CD%
echo Project path: %~dp0
echo Scene path: res://scenes/hortus_conclusus_cinematic_recording.tscn
echo.

echo Press any key to start recording or Ctrl+C to cancel.
pause > nul

echo.
echo Launching Godot with the recording scene...
echo Command: %GODOT_PATH% --path "%~dp0" --scene "res://scenes/hortus_conclusus_cinematic_recording.tscn"
echo.

REM Launch Godot with the recording scene
%GODOT_PATH% --path "%~dp0" --scene "res://scenes/hortus_conclusus_cinematic_recording.tscn"

echo.
echo Godot process completed with exit code: %ERRORLEVEL%
echo.
echo If recording was successful, the PNG image sequence should be saved at:
echo %APPDATA%\Godot\app_userdata\Hortus Conclusis\screenshots\
echo.
echo Checking if the directory exists...

if exist "%APPDATA%\Godot\app_userdata\Hortus Conclusis\screenshots\" (
    echo SUCCESS: Screenshots directory found!
    echo Files in directory: 
    dir "%APPDATA%\Godot\app_userdata\Hortus Conclusis\screenshots\" | find "frame_"
) else (
    echo ERROR: Screenshots directory not found.
    echo Please check the Godot console for error messages.
)

echo.
echo To create a video from these images, you can use a video editing tool like:
echo - FFmpeg (command line): ffmpeg -framerate 30 -i frame_%%06d.png -c:v libx264 -pix_fmt yuv420p cinematic.mp4
echo - Adobe Premiere Pro
echo - DaVinci Resolve
echo - Windows Video Editor
echo.
echo Press any key to exit.
pause > nul
