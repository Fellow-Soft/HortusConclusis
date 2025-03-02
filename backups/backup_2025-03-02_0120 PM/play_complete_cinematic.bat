@echo off
echo Starting Complete Hortus Conclusus Cinematic Experience...
echo.

REM Change to the directory where Godot is installed
cd ..\..\Godot

REM Run the complete cinematic scene with our combined script
godot.exe --path "C:\Users\joshu\PycharmProjects\Kasumi\HortusConclusis" --scene "scenes/hortus_conclusus_cinematic.tscn"

echo.
echo Cinematic experience completed.
echo.
echo Press any key to exit...
pause > nul
