@echo off
echo Cleaning up old cinematic files...
echo.

REM Remove old cinematic script files
echo Removing old cinematic script files...
del /q "scripts\hortus_conclusus_cinematic_new.gd"
del /q "scripts\hortus_conclusus_cinematic_enhanced.gd"
del /q "scripts\hortus_conclusus_cinematic_final.gd"

REM Remove old batch files
echo Removing old batch files...
del /q "play_title_cinematic.bat"
del /q "play_enhanced_cinematic.bat"
del /q "run_title_cinematic.bat"
del /q "run_title_cinematic.ps1"

REM Remove old documentation files
echo Removing old documentation files...
del /q "CINEMATIC_EXPERIENCE_ANALYSIS.md"
del /q "CINEMATIC_EXPERIENCE_SUMMARY.md"
del /q "CINEMATIC_EXPERIENCE_ENHANCED.md"
del /q "CINEMATIC_TITLE_SCREEN.md"
del /q "TITLE_SCREEN_IMPLEMENTATION.md"
del /q "CINEMATIC_ISSUES.md"
del /q "CINEMATIC_IMPLEMENTATION_PLAN.md"
del /q "CINEMATIC_ENHANCEMENTS.md"
del /q "CINEMATIC_ART_DIRECTION.md"
del /q "CINEMATIC_ART_DIRECTION_DETAILED.md"
del /q "CINEMATIC_IMPLEMENTATION_DETAILED.md"

echo.
echo Cleanup completed. All old cinematic files have been removed.
echo The complete cinematic experience is now available through:
echo - scripts\hortus_conclusus_cinematic_complete.gd
echo - play_complete_cinematic.bat
echo - CINEMATIC_EXPERIENCE_COMPLETE.md
echo.
echo Press any key to exit...
pause > nul
