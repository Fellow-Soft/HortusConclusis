@echo off
echo Archiving sacred geometry helper functions...
echo.

REM Create archive directory if it doesn't exist
if not exist "archive\scripts\sacred_geometry" mkdir "archive\scripts\sacred_geometry"

REM Move the helper file to archive
if exist "scripts\geometry\sacred_geometry_helpers.gd" (
    move "scripts\geometry\sacred_geometry_helpers.gd" "archive\scripts\sacred_geometry\sacred_geometry_helpers.gd"
    echo Moved sacred_geometry_helpers.gd to archive.
) else (
    echo sacred_geometry_helpers.gd not found.
)

REM Update reference mapping
echo. >> reference_mapping.md
echo ## Helper Function Consolidation >> reference_mapping.md
echo. >> reference_mapping.md
echo | Original Helper File | Consolidated Into | >> reference_mapping.md
echo | ------------------- | ----------------- | >> reference_mapping.md
echo | scripts/geometry/sacred_geometry_helpers.gd | scripts/geometry/sacred_geometry.gd | >> reference_mapping.md

echo.
echo Helper functions have been archived and reference mapping has been updated.
echo Press any key to exit...
pause > nul
