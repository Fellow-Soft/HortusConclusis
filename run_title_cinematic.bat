@echo off
echo Starting Hortus Conclusus Cinematic Experience with Title Screen...
echo.

REM Try to find Godot in common locations
set GODOT_PATH=godot.exe

REM Run the cinematic scene with our title screen script
%GODOT_PATH% --path "%~dp0" --scene "scenes/hortus_conclusus_cinematic.tscn" --script "scripts/hortus_conclusus_cinematic_new.gd"

echo.
echo Cinematic experience completed.
echo.
pause
