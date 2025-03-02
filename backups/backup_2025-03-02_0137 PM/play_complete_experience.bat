@echo off
echo Starting Hortus Conclusus Complete Experience...
echo.
echo This will play the title screen, followed by the cinematic demo,
echo and then load into the main game experience.
echo.

REM Run the title screen scene which will transition to the rest of the experience
"C:\Users\joshu\Godot\godot.exe" --path "C:\Users\joshu\PycharmProjects\Kasumi\HortusConclusis" --scene "scenes/title_screen_cinematic.tscn" --complete-experience

echo.
echo Complete experience finished.
echo.
echo Press any key to exit...
pause > nul
