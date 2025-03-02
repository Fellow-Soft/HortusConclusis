@echo off
echo Archiving old cinematic files...
echo.

REM Move old cinematic script files to archive/scripts
echo Moving old cinematic script files...
move "scripts\hortus_conclusus_cinematic_new.gd" "archive\scripts\"
move "scripts\hortus_conclusus_cinematic_enhanced.gd" "archive\scripts\"
move "scripts\hortus_conclusus_cinematic_final.gd" "archive\scripts\"
move "scripts\sacred_geometry_enhanced_complete.gd" "archive\scripts\"
move "scripts\sacred_geometry_enhanced_final.gd" "archive\scripts\"
move "scripts\sacred_geometry_enhanced_complete_final.gd" "archive\scripts\"
move "scripts\sacred_geometry_enhanced_complete_version.gd" "archive\scripts\"
move "scripts\sacred_geometry_enhanced_final_complete.gd" "archive\scripts\"

REM Move old batch files to archive/batch
echo Moving old batch files...
move "play_title_cinematic.bat" "archive\batch\"
move "play_enhanced_cinematic.bat" "archive\batch\"
move "run_title_cinematic.bat" "archive\batch\"
move "run_title_cinematic.ps1" "archive\batch\"
move "setup_enhanced_cinematic.bat" "archive\batch\"

REM Move old documentation files to archive/docs
echo Moving old documentation files...
move "CINEMATIC_EXPERIENCE_ANALYSIS.md" "archive\docs\"
move "CINEMATIC_EXPERIENCE_SUMMARY.md" "archive\docs\"
move "CINEMATIC_EXPERIENCE_ENHANCED.md" "archive\docs\"
move "CINEMATIC_TITLE_SCREEN.md" "archive\docs\"
move "TITLE_SCREEN_IMPLEMENTATION.md" "archive\docs\"
move "CINEMATIC_ISSUES.md" "archive\docs\"
move "CINEMATIC_IMPLEMENTATION_PLAN.md" "archive\docs\"
move "CINEMATIC_ENHANCEMENTS.md" "archive\docs\"
move "CINEMATIC_ART_DIRECTION.md" "archive\docs\"
move "CINEMATIC_ART_DIRECTION_DETAILED.md" "archive\docs\"
move "CINEMATIC_IMPLEMENTATION_DETAILED.md" "archive\docs\"
move "ENHANCED_CAMERA_SYSTEM.md" "archive\docs\"
move "ENHANCED_MEDITATION_DISPLAY.md" "archive\docs\"
move "ENHANCED_ATMOSPHERE_SYSTEM.md" "archive\docs\"

echo.
echo Archiving completed. All old cinematic files have been moved to the archive directory.
echo The complete cinematic experience is now available through:
echo - scripts\hortus_conclusus_cinematic_complete.gd
echo - play_complete_cinematic.bat
echo - CINEMATIC_EXPERIENCE_COMPLETE.md
echo.
echo Press any key to exit...
pause > nul
