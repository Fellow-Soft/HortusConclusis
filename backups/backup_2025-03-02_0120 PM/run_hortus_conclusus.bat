@echo off
echo Hortus Conclusus Experience Launcher
echo ==================================
echo.
echo This script provides options to run different aspects of the Hortus Conclusus project.
echo.

:menu
echo Please select an option:
echo.
echo 1. Run Complete Experience (title screen + cinematic + garden)
echo 2. Run Cinematic Only
echo 3. Run Medieval Garden Demo
echo 4. Run Texture Shader Demo
echo 5. Run Meditation Display
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto complete_experience
if "%choice%"=="2" goto cinematic_only
if "%choice%"=="3" goto garden_demo
if "%choice%"=="4" goto texture_demo
if "%choice%"=="5" goto meditation_display
if "%choice%"=="6" goto end

echo.
echo Invalid choice. Please try again.
echo.
goto menu

:complete_experience
echo.
echo Starting Complete Hortus Conclusus Experience...
echo.
echo This will play the title screen, followed by the cinematic demo,
echo and then load into the main garden experience.
echo.
"C:\Users\joshu\Godot\godot.exe" --path "%~dp0" --scene "scenes/hortus_conclusus_cinematic.tscn" --complete-experience
goto end

:cinematic_only
echo.
echo Starting Hortus Conclusus Cinematic Experience...
echo.
"C:\Users\joshu\Godot\godot.exe" --path "%~dp0" --scene "scenes/hortus_conclusus_cinematic.tscn"
goto end

:garden_demo
echo.
echo Starting Medieval Garden Demo...
echo.
"C:\Users\joshu\Godot\godot.exe" --path "%~dp0" --scene "scenes/medieval_garden_demo.tscn"
goto end

:texture_demo
echo.
echo Starting Texture Shader Demo...
echo.
"C:\Users\joshu\Godot\godot.exe" --path "%~dp0" --scene "scenes/texture_shader_demo.tscn"
goto end

:meditation_display
echo.
echo Starting Meditation Display...
echo.
"C:\Users\joshu\Godot\godot.exe" --path "%~dp0" --scene "scenes/meditation_display.tscn"
goto end

:end
echo.
echo Experience completed.
echo.
echo Press any key to exit...
pause > nul
