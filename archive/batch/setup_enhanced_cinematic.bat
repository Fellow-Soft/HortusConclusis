@echo off
echo Setting up enhanced cinematic scene...
echo.

REM Change to the directory where Godot is installed
cd ..\..\Godot

REM Run the setup scene
godot.exe --path "../PycharmProjects/Kasumi/HortusConclusis" --scene "scenes/setup_enhanced_cinematic.tscn"

echo.
echo Setup complete!
echo.
echo To use the enhanced cinematic scene:
echo 1. Open the Hortus Conclusus project in Godot
echo 2. Open the hortus_conclusus_cinematic.tscn scene
echo 3. Hide or remove the original cinematic controller
echo 4. Make sure the enhanced cinematic controller is active
echo.
echo Press any key to exit...
pause > nul
