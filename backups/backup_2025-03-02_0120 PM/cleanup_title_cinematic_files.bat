@echo off
echo Organizing and cleaning up title screen and cinematic files...
echo.

REM Create archive directory if it doesn't exist
if not exist "archive\scripts" mkdir "archive\scripts"
if not exist "archive\docs" mkdir "archive\docs"
if not exist "archive\batch" mkdir "archive\batch"

REM Archive old title screen script
echo Archiving old title screen script...
if exist "scripts\title_screen_cinematic.gd" (
    move "scripts\title_screen_cinematic.gd" "archive\scripts\title_screen_cinematic.gd"
    echo - Moved title_screen_cinematic.gd to archive
) else (
    echo - title_screen_cinematic.gd not found, skipping
)

REM Archive outdated documentation files
echo Archiving outdated documentation...
if exist "CINEMATIC_TITLE_SCREEN.md" (
    move "CINEMATIC_TITLE_SCREEN.md" "archive\docs\CINEMATIC_TITLE_SCREEN.md"
    echo - Moved CINEMATIC_TITLE_SCREEN.md to archive
) else (
    echo - CINEMATIC_TITLE_SCREEN.md not found, skipping
)

if exist "TITLE_SCREEN_IMPLEMENTATION.md" (
    move "TITLE_SCREEN_IMPLEMENTATION.md" "archive\docs\TITLE_SCREEN_IMPLEMENTATION.md"
    echo - Moved TITLE_SCREEN_IMPLEMENTATION.md to archive
) else (
    echo - TITLE_SCREEN_IMPLEMENTATION.md not found, skipping
)

REM Archive old batch files
echo Archiving outdated batch files...
if exist "run_title_cinematic.ps1" (
    move "run_title_cinematic.ps1" "archive\batch\run_title_cinematic.ps1"
    echo - Moved run_title_cinematic.ps1 to archive
) else (
    echo - run_title_cinematic.ps1 not found, skipping
)

if exist "play_title_cinematic.bat" (
    move "play_title_cinematic.bat" "archive\batch\play_title_cinematic.bat"
    echo - Moved play_title_cinematic.bat to archive
) else (
    echo - play_title_cinematic.bat not found, skipping
)

echo.
echo Cleanup complete. New files are in place and old files have been archived.
echo.
echo Press any key to exit...
pause > nul
