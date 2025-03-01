@echo off
echo Starting Hortus Conclusus Cinematic Experience with Title Screen...
echo.

REM Change to the directory where Godot is installed
cd ..\..\Godot

REM Run the cinematic scene with our title screen script
godot.exe --path "../PycharmProjects/Kasumi/HortusConclusis" --scene "scenes/hortus_conclusus_cinematic.tscn" --script "scripts/hortus_conclusus_cinematic_new.gd"

echo.
echo Cinematic experience completed.
echo.
echo Press any key to exit...
pause > nul
