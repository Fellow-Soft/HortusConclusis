@echo off
echo Hortus Conclusus Project Cleanup
echo ===============================
echo.
echo This script will organize redundant files into the archive directory while preserving all functionality.
echo No files will be deleted - only moved to the archive directory with a preserved structure.
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul
echo.

REM Create archive directories with structure mirroring the main project
echo Creating archive directory structure...
if not exist "archive\scripts\atmosphere" mkdir "archive\scripts\atmosphere"
if not exist "archive\scripts\cinematic" mkdir "archive\scripts\cinematic"
if not exist "archive\scripts\meditation" mkdir "archive\scripts\meditation"
if not exist "archive\scripts\camera" mkdir "archive\scripts\camera"
if not exist "archive\scripts\effects" mkdir "archive\scripts\effects"
if not exist "archive\scripts\sacred_geometry" mkdir "archive\scripts\sacred_geometry"
if not exist "archive\batch" mkdir "archive\batch"
if not exist "archive\docs\cinematic" mkdir "archive\docs\cinematic"
if not exist "archive\docs\ambrose" mkdir "archive\docs\ambrose"
if not exist "archive\scenes\cinematic" mkdir "archive\scenes\cinematic"
if not exist "archive\scenes\title" mkdir "archive\scenes\title"

echo.
echo 1. Backing up current project state...
echo ----------------------------------
echo Creating backup of current project state before making changes...

REM Create a backup directory with timestamp
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set backup_dir=backup_%mydate%_%mytime%
mkdir %backup_dir%

REM Copy important files to backup
xcopy /E /I /Y "scripts" "%backup_dir%\scripts"
xcopy /E /I /Y "scenes" "%backup_dir%\scenes"
xcopy /Y "*.md" "%backup_dir%\"
xcopy /Y "*.bat" "%backup_dir%\"

echo Backup created in %backup_dir% directory.

echo.
echo 2. Consolidating batch files...
echo ------------------------------

REM Move redundant batch files to archive with descriptive names
echo Moving redundant batch files to archive...
if exist "archive_cinematic_files.bat" move "archive_cinematic_files.bat" "archive\batch\archive_cinematic_files.bat"
if exist "cleanup_cinematic_files.bat" move "cleanup_cinematic_files.bat" "archive\batch\cleanup_cinematic_files.bat"
if exist "cleanup_title_cinematic_files.bat" move "cleanup_title_cinematic_files.bat" "archive\batch\cleanup_title_cinematic_files.bat"
if exist "record_cinematic_simple.bat" move "record_cinematic_simple.bat" "archive\batch\record_cinematic_simple.bat"
if exist "record_cinematic.bat" move "record_cinematic.bat" "archive\batch\record_cinematic.bat"
if exist "run_title_cinematic.bat" move "run_title_cinematic.bat" "archive\batch\run_title_cinematic.bat"
if exist "cleanup_consolidated_files.bat" move "cleanup_consolidated_files.bat" "archive\batch\cleanup_consolidated_files.bat"

echo.
echo 3. Consolidating redundant script files...
echo ---------------------------------------

REM Move redundant atmosphere controller scripts to archive
echo Moving redundant atmosphere controller scripts...
if exist "scripts\atmosphere_controller.gd" move "scripts\atmosphere_controller.gd" "archive\scripts\atmosphere\atmosphere_controller.gd"
if exist "scripts\atmosphere_controller_advanced.gd" move "scripts\atmosphere_controller_advanced.gd" "archive\scripts\atmosphere\atmosphere_controller_advanced.gd"

REM Keep only the enhanced version of atmosphere controller
echo Keeping only atmosphere_controller_enhanced.gd...

REM Move redundant cinematic scripts to archive
echo Moving redundant cinematic scripts...
if exist "scripts\hortus_conclusus_cinematic.gd" move "scripts\hortus_conclusus_cinematic.gd" "archive\scripts\cinematic\hortus_conclusus_cinematic.gd"
if exist "scripts\hortus_conclusus_cinematic_missing_functions.gd" move "scripts\hortus_conclusus_cinematic_missing_functions.gd" "archive\scripts\cinematic\hortus_conclusus_cinematic_missing_functions.gd"
if exist "scripts\hortus_conclusus_cinematic_new.gd" move "scripts\hortus_conclusus_cinematic_new.gd" "archive\scripts\cinematic\hortus_conclusus_cinematic_new.gd"
if exist "scripts\hortus_conclusus_cinematic_helpers.gd" move "scripts\hortus_conclusus_cinematic_helpers.gd" "archive\scripts\cinematic\hortus_conclusus_cinematic_helpers.gd"
if exist "scripts\hortus_conclusus_cinematic_connections.gd" move "scripts\hortus_conclusus_cinematic_connections.gd" "archive\scripts\cinematic\hortus_conclusus_cinematic_connections.gd"
if exist "scripts\hortus_conclusus_cinematic_integration.gd" move "scripts\hortus_conclusus_cinematic_integration.gd" "archive\scripts\cinematic\hortus_conclusus_cinematic_integration.gd"

REM Keep only the complete version of the cinematic script
echo Keeping only hortus_conclusus_cinematic_complete.gd...

REM Move redundant meditation display scripts to archive
echo Moving redundant meditation display scripts...
if exist "scripts\meditation_display.gd" move "scripts\meditation_display.gd" "archive\scripts\meditation\meditation_display.gd"
if exist "scripts\meditation_display_advanced.gd" move "scripts\meditation_display_advanced.gd" "archive\scripts\meditation\meditation_display_advanced.gd"
if exist "scripts\meditation_display_integration.gd" move "scripts\meditation_display_integration.gd" "archive\scripts\meditation\meditation_display_integration.gd"

REM Keep only the enhanced version of meditation display
echo Keeping only meditation_display_enhanced.gd...

REM Move redundant camera scripts to archive
echo Moving redundant camera scripts...
if exist "scripts\camera_system.gd" move "scripts\camera_system.gd" "archive\scripts\camera\camera_system.gd"
if exist "scripts\camera_path.gd" move "scripts\camera_path.gd" "archive\scripts\camera\camera_path.gd"
if exist "scripts\camera_path_integration.gd" move "scripts\camera_path_integration.gd" "archive\scripts\camera\camera_path_integration.gd"

REM Keep only the enhanced versions of camera scripts
echo Keeping only camera_system_enhanced.gd and camera_path_enhanced.gd...

REM Move redundant cinematic effects scripts to archive
echo Moving redundant cinematic effects scripts...
if exist "scripts\cinematic_effects.gd" move "scripts\cinematic_effects.gd" "archive\scripts\effects\cinematic_effects.gd"

REM Keep only the enhanced version of cinematic effects
echo Keeping only cinematic_effects_enhanced.gd...

REM Move redundant sacred geometry scripts to archive
echo Moving redundant sacred geometry scripts...
if exist "scripts\sacred_geometry.gd" move "scripts\sacred_geometry.gd" "archive\scripts\sacred_geometry\sacred_geometry.gd"

echo.
echo 4. Consolidating scene files...
echo ----------------------------

REM Create a list of redundant scene files
echo Identifying redundant scene files...
set "redundant_scenes=scenes\hortus_conclusus_cinematic_recording.tscn scenes\setup_enhanced_cinematic.tscn scenes\title_screen_cinematic.tscn"

REM Move redundant scene files to archive
echo Moving redundant scene files to archive...
if exist "scenes\hortus_conclusus_cinematic_recording.tscn" move "scenes\hortus_conclusus_cinematic_recording.tscn" "archive\scenes\cinematic\hortus_conclusus_cinematic_recording.tscn"
if exist "scenes\setup_enhanced_cinematic.tscn" move "scenes\setup_enhanced_cinematic.tscn" "archive\scenes\cinematic\setup_enhanced_cinematic.tscn"
if exist "scenes\title_screen_cinematic.tscn" move "scenes\title_screen_cinematic.tscn" "archive\scenes\title\title_screen_cinematic.tscn"

echo.
echo 5. Consolidating documentation files...
echo -----------------------------------

REM Move original documentation files to archive
echo Moving original documentation files to archive...
if exist "CINEMATIC_ANALYSIS.md" move "CINEMATIC_ANALYSIS.md" "archive\docs\cinematic\CINEMATIC_ANALYSIS.md"
if exist "CINEMATIC_ENHANCEMENT_PLAN.md" move "CINEMATIC_ENHANCEMENT_PLAN.md" "archive\docs\cinematic\CINEMATIC_ENHANCEMENT_PLAN.md"
if exist "CINEMATIC_WALKTHROUGH.md" move "CINEMATIC_WALKTHROUGH.md" "archive\docs\cinematic\CINEMATIC_WALKTHROUGH.md"
if exist "ENHANCED_TITLE_AND_CINEMATIC.md" move "ENHANCED_TITLE_AND_CINEMATIC.md" "archive\docs\cinematic\ENHANCED_TITLE_AND_CINEMATIC.md"
if exist "GARDENER_PERSONA.md" move "GARDENER_PERSONA.md" "archive\docs\ambrose\GARDENER_PERSONA.md"
if exist "CUSTOM_INSTRUCTION.md" move "CUSTOM_INSTRUCTION.md" "archive\docs\ambrose\CUSTOM_INSTRUCTION.md"

echo.
echo 6. Creating reference mapping file...
echo ----------------------------------

REM Create a reference mapping file instead of automatically updating references
echo Creating reference mapping file...
echo # Reference Mapping for Archived Files > reference_mapping.md
echo. >> reference_mapping.md
echo This file provides a mapping between archived files and their current replacements. >> reference_mapping.md
echo Use this as a guide if you need to update references manually. >> reference_mapping.md
echo. >> reference_mapping.md
echo ## Script References >> reference_mapping.md
echo. >> reference_mapping.md
echo | Original File | Replacement File | >> reference_mapping.md
echo | ------------- | ---------------- | >> reference_mapping.md
echo | atmosphere_controller.gd | atmosphere_controller_enhanced.gd | >> reference_mapping.md
echo | atmosphere_controller_advanced.gd | atmosphere_controller_enhanced.gd | >> reference_mapping.md
echo | hortus_conclusus_cinematic.gd | hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | hortus_conclusus_cinematic_missing_functions.gd | hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | hortus_conclusus_cinematic_new.gd | hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | hortus_conclusus_cinematic_helpers.gd | hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | hortus_conclusus_cinematic_connections.gd | hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | hortus_conclusus_cinematic_integration.gd | hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | meditation_display.gd | meditation_display_enhanced.gd | >> reference_mapping.md
echo | meditation_display_advanced.gd | meditation_display_enhanced.gd | >> reference_mapping.md
echo | meditation_display_integration.gd | meditation_display_enhanced.gd | >> reference_mapping.md
echo | camera_system.gd | camera_system_enhanced.gd | >> reference_mapping.md
echo | camera_path.gd | camera_path_enhanced.gd | >> reference_mapping.md
echo | camera_path_integration.gd | camera_path_enhanced.gd | >> reference_mapping.md
echo | cinematic_effects.gd | cinematic_effects_enhanced.gd | >> reference_mapping.md
echo | sacred_geometry.gd | sacred_geometry_enhanced.gd | >> reference_mapping.md
echo. >> reference_mapping.md
echo ## Scene References >> reference_mapping.md
echo. >> reference_mapping.md
echo | Original Scene | Replacement Scene | >> reference_mapping.md
echo | -------------- | ----------------- | >> reference_mapping.md
echo | scenes/hortus_conclusus_cinematic_recording.tscn | scenes/hortus_conclusus_cinematic.tscn | >> reference_mapping.md
echo | scenes/setup_enhanced_cinematic.tscn | scenes/hortus_conclusus_cinematic.tscn | >> reference_mapping.md
echo | scenes/title_screen_cinematic.tscn | scenes/hortus_conclusus_cinematic.tscn | >> reference_mapping.md
echo. >> reference_mapping.md
echo ## Documentation References >> reference_mapping.md
echo. >> reference_mapping.md
echo | Original Document | Replacement Document | >> reference_mapping.md
echo | ----------------- | -------------------- | >> reference_mapping.md
echo | CINEMATIC_ANALYSIS.md | CINEMATIC_DEVELOPMENT.md | >> reference_mapping.md
echo | CINEMATIC_ENHANCEMENT_PLAN.md | CINEMATIC_DEVELOPMENT.md | >> reference_mapping.md
echo | CINEMATIC_WALKTHROUGH.md | CINEMATIC_EXPERIENCE_COMPLETE.md | >> reference_mapping.md
echo | ENHANCED_TITLE_AND_CINEMATIC.md | CINEMATIC_DEVELOPMENT.md | >> reference_mapping.md
echo | GARDENER_PERSONA.md | AMBROSE_THE_GARDENER.md | >> reference_mapping.md
echo | CUSTOM_INSTRUCTION.md | AMBROSE_THE_GARDENER.md | >> reference_mapping.md

echo.
echo 7. Creating archive documentation...
echo ---------------------------------

REM Create a README for the archive directory
echo Creating archive README...
echo # Archive Directory > archive\README.md
echo. >> archive\README.md
echo This directory contains files that have been archived during project cleanup and consolidation. >> archive\README.md
echo All files are preserved for reference but are no longer actively used in the project. >> archive\README.md
echo. >> archive\README.md
echo ## Directory Structure >> archive\README.md
echo. >> archive\README.md
echo - **batch/**: Archived batch files >> archive\README.md
echo   - Various batch files for running different aspects of the project >> archive\README.md
echo. >> archive\README.md
echo - **docs/**: Archived documentation files >> archive\README.md
echo   - **cinematic/**: Original cinematic documentation >> archive\README.md
echo   - **ambrose/**: Original Ambrose persona documentation >> archive\README.md
echo. >> archive\README.md
echo - **scripts/**: Archived script files >> archive\README.md
echo   - **atmosphere/**: Atmosphere controller scripts >> archive\README.md
echo   - **cinematic/**: Cinematic implementation scripts >> archive\README.md
echo   - **meditation/**: Meditation display scripts >> archive\README.md
echo   - **camera/**: Camera system scripts >> archive\README.md
echo   - **effects/**: Visual effects scripts >> archive\README.md
echo   - **sacred_geometry/**: Sacred geometry visualization scripts >> archive\README.md
echo. >> archive\README.md
echo - **scenes/**: Archived scene files >> archive\README.md
echo   - **cinematic/**: Cinematic scene files >> archive\README.md
echo   - **title/**: Title screen scene files >> archive\README.md
echo. >> archive\README.md
echo ## Reference Mapping >> archive\README.md
echo. >> archive\README.md
echo See the `reference_mapping.md` file in the main project directory for a mapping between archived files and their current replacements. >> archive\README.md

echo.
echo Cleanup completed successfully!
echo.
echo The following files have been kept as the primary versions:
echo - scripts/hortus_conclusus_cinematic_complete.gd
echo - scripts/atmosphere_controller_enhanced.gd
echo - scripts/meditation_display_enhanced.gd
echo - scripts/camera_system_enhanced.gd
echo - scripts/camera_path_enhanced.gd
echo - scripts/cinematic_effects_enhanced.gd
echo - scripts/sacred_geometry_enhanced.gd
echo.
echo The following batch files have been kept:
echo - play_complete_cinematic.bat
echo - play_complete_experience.bat
echo - run_hortus_conclusus.bat (new unified launcher)
echo.
echo The following documentation files have been consolidated:
echo - CINEMATIC_DEVELOPMENT.md
echo - CINEMATIC_EXPERIENCE_COMPLETE.md
echo - AMBROSE_THE_GARDENER.md
echo - README.md (reorganized)
echo - TASKS.md (streamlined)
echo - PROJECT_STRUCTURE.md (new project structure documentation)
echo - reference_mapping.md (new reference mapping documentation)
echo.
echo IMPORTANT: This script has NOT automatically updated references in the remaining files.
echo Instead, it has created a reference_mapping.md file that you can use as a guide
echo for manually updating references if needed.
echo.
echo Press any key to exit...
pause > nul
