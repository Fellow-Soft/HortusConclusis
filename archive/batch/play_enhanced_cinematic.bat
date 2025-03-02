@echo off
echo Starting Enhanced Hortus Conclusus Cinematic Experience...
echo.

REM Change to the directory where Godot is installed
cd ..\..\Godot

REM Run the enhanced cinematic scene
godot.exe --path "../PycharmProjects/Kasumi/HortusConclusis" --scene "scenes/hortus_conclusus_cinematic.tscn" --script "scripts/hortus_conclusus_cinematic_enhanced.gd"

echo.
echo Cinematic experience completed.
echo.
echo Press any key to exit...
pause > nul
