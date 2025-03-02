@echo off
echo Hortus Conclusus Script Organization
echo =====================================
echo.
echo This script will reorganize the scripts directory into a modular structure.
echo No files will be deleted - only moved to their appropriate subdirectories.
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul
echo.

REM Create backup of current scripts directory
echo Creating backup of scripts directory...
set backup_dir=backup_scripts_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%
mkdir %backup_dir%
xcopy /E /I /Y "scripts" "%backup_dir%\scripts"
echo Backup created in %backup_dir% directory.
echo.

REM Create the new directory structure
echo Creating new directory structure...
if not exist "scripts\core" mkdir "scripts\core"
if not exist "scripts\cinematic" mkdir "scripts\cinematic"
if not exist "scripts\environment" mkdir "scripts\environment"
if not exist "scripts\camera" mkdir "scripts\camera"
if not exist "scripts\meditation" mkdir "scripts\meditation"
if not exist "scripts\geometry" mkdir "scripts\geometry"
if not exist "scripts\ui" mkdir "scripts\ui"
if not exist "scripts\generation" mkdir "scripts\generation"
if not exist "scripts\demo" mkdir "scripts\demo"

REM Move core scripts
echo Moving core scripts...
if exist "scripts\main.gd" move "scripts\main.gd" "scripts\core\"
if exist "scripts\up_vector_handler.gd" move "scripts\up_vector_handler.gd" "scripts\core\"

REM Move cinematic scripts
echo Moving cinematic scripts...
if exist "scripts\hortus_conclusus_cinematic_complete.gd" move "scripts\hortus_conclusus_cinematic_complete.gd" "scripts\cinematic\"
if exist "scripts\cinematic_effects_enhanced.gd" move "scripts\cinematic_effects_enhanced.gd" "scripts\cinematic\"
if exist "scripts\cinematic_recorder.gd" move "scripts\cinematic_recorder.gd" "scripts\cinematic\"
if exist "scripts\cinematic_transition.gd" move "scripts\cinematic_transition.gd" "scripts\cinematic\"
if exist "scripts\cinematic_meditation_display.gd" move "scripts\cinematic_meditation_display.gd" "scripts\cinematic\"

REM Move environment scripts
echo Moving environment scripts...
if exist "scripts\atmosphere_controller_enhanced.gd" move "scripts\atmosphere_controller_enhanced.gd" "scripts\environment\"
if exist "scripts\terrain_generator.gd" move "scripts\terrain_generator.gd" "scripts\environment\"

REM Move camera scripts
echo Moving camera scripts...
if exist "scripts\camera_system_enhanced.gd" move "scripts\camera_system_enhanced.gd" "scripts\camera\"
if exist "scripts\camera_path_enhanced.gd" move "scripts\camera_path_enhanced.gd" "scripts\camera\"

REM Move meditation scripts
echo Moving meditation scripts...
if exist "scripts\meditation_display_enhanced.gd" move "scripts\meditation_display_enhanced.gd" "scripts\meditation\"

REM Move geometry scripts
echo Moving geometry scripts...
if exist "scripts\sacred_geometry_enhanced.gd" move "scripts\sacred_geometry_enhanced.gd" "scripts\geometry\"
if exist "scripts\sacred_geometry_enhanced_helpers.gd" move "scripts\sacred_geometry_enhanced_helpers.gd" "scripts\geometry\"
if exist "scripts\l_system.gd" move "scripts\l_system.gd" "scripts\geometry\"
if exist "scripts\path_generator.gd" move "scripts\path_generator.gd" "scripts\geometry\"

REM Move UI scripts
echo Moving UI scripts...
if exist "scripts\illuminated_title.gd" move "scripts\illuminated_title.gd" "scripts\ui\"
if exist "scripts\medieval_ambrose_interface.gd" move "scripts\medieval_ambrose_interface.gd" "scripts\ui\"
if exist "scripts\splash_screen.gd" move "scripts\splash_screen.gd" "scripts\ui\"

REM Move generation tools and utilities
echo Moving generation tools and utilities...
if exist "scripts\border_generator_tool.gd" move "scripts\border_generator_tool.gd" "scripts\generation\"
if exist "scripts\generate_illuminated_borders.gd" move "scripts\generate_illuminated_borders.gd" "scripts\generation\"
if exist "scripts\placement_system.gd" move "scripts\placement_system.gd" "scripts\generation\"
if exist "scripts\medieval_texture_generator.py" move "scripts\medieval_texture_generator.py" "scripts\generation\"
if exist "scripts\texture_generator.py" move "scripts\texture_generator.py" "scripts\generation\"
if exist "scripts\medieval_texture_shader_integrator.py" move "scripts\medieval_texture_shader_integrator.py" "scripts\generation\"
if exist "scripts\create_medieval_music.py" move "scripts\create_medieval_music.py" "scripts\generation\"
if exist "scripts\create_ui_assets.py" move "scripts\create_ui_assets.py" "scripts\generation\"

REM Move demo scene scripts
echo Moving demo scene scripts...
if exist "scripts\medieval_garden_demo.gd" move "scripts\medieval_garden_demo.gd" "scripts\demo\"
if exist "scripts\medieval_herb_garden_demo.gd" move "scripts\medieval_herb_garden_demo.gd" "scripts\demo\"
if exist "scripts\texture_shader_demo.gd" move "scripts\texture_shader_demo.gd" "scripts\demo\"
if exist "scripts\setup_enhanced_cinematic.gd" move "scripts\setup_enhanced_cinematic.gd" "scripts\demo\"

REM Update resource references file
echo Updating reference mapping file...
echo. >> reference_mapping.md
echo ## Script Path Updates >> reference_mapping.md
echo. >> reference_mapping.md
echo | Original Path | New Path | >> reference_mapping.md
echo | ------------- | -------- | >> reference_mapping.md
echo | scripts/main.gd | scripts/core/main.gd | >> reference_mapping.md
echo | scripts/up_vector_handler.gd | scripts/core/up_vector_handler.gd | >> reference_mapping.md
echo | scripts/hortus_conclusus_cinematic_complete.gd | scripts/cinematic/hortus_conclusus_cinematic_complete.gd | >> reference_mapping.md
echo | scripts/cinematic_effects_enhanced.gd | scripts/cinematic/cinematic_effects_enhanced.gd | >> reference_mapping.md
echo | scripts/cinematic_recorder.gd | scripts/cinematic/cinematic_recorder.gd | >> reference_mapping.md
echo | scripts/cinematic_transition.gd | scripts/cinematic/cinematic_transition.gd | >> reference_mapping.md
echo | scripts/cinematic_meditation_display.gd | scripts/cinematic/cinematic_meditation_display.gd | >> reference_mapping.md
echo | scripts/atmosphere_controller_enhanced.gd | scripts/environment/atmosphere_controller_enhanced.gd | >> reference_mapping.md
echo | scripts/terrain_generator.gd | scripts/environment/terrain_generator.gd | >> reference_mapping.md
echo | scripts/camera_system_enhanced.gd | scripts/camera/camera_system_enhanced.gd | >> reference_mapping.md
echo | scripts/camera_path_enhanced.gd | scripts/camera/camera_path_enhanced.gd | >> reference_mapping.md
echo | scripts/meditation_display_enhanced.gd | scripts/meditation/meditation_display_enhanced.gd | >> reference_mapping.md
echo | scripts/sacred_geometry_enhanced.gd | scripts/geometry/sacred_geometry_enhanced.gd | >> reference_mapping.md
echo | scripts/sacred_geometry_enhanced_helpers.gd | scripts/geometry/sacred_geometry_enhanced_helpers.gd | >> reference_mapping.md
echo | scripts/l_system.gd | scripts/geometry/l_system.gd | >> reference_mapping.md
echo | scripts/path_generator.gd | scripts/geometry/path_generator.gd | >> reference_mapping.md
echo | scripts/illuminated_title.gd | scripts/ui/illuminated_title.gd | >> reference_mapping.md
echo | scripts/medieval_ambrose_interface.gd | scripts/ui/medieval_ambrose_interface.gd | >> reference_mapping.md
echo | scripts/splash_screen.gd | scripts/ui/splash_screen.gd | >> reference_mapping.md
echo | scripts/border_generator_tool.gd | scripts/generation/border_generator_tool.gd | >> reference_mapping.md
echo | scripts/generate_illuminated_borders.gd | scripts/generation/generate_illuminated_borders.gd | >> reference_mapping.md
echo | scripts/placement_system.gd | scripts/generation/placement_system.gd | >> reference_mapping.md
echo | scripts/medieval_texture_generator.py | scripts/generation/medieval_texture_generator.py | >> reference_mapping.md
echo | scripts/texture_generator.py | scripts/generation/texture_generator.py | >> reference_mapping.md
echo | scripts/medieval_texture_shader_integrator.py | scripts/generation/medieval_texture_shader_integrator.py | >> reference_mapping.md
echo | scripts/create_medieval_music.py | scripts/generation/create_medieval_music.py | >> reference_mapping.md
echo | scripts/create_ui_assets.py | scripts/generation/create_ui_assets.py | >> reference_mapping.md
echo | scripts/medieval_garden_demo.gd | scripts/demo/medieval_garden_demo.gd | >> reference_mapping.md
echo | scripts/medieval_herb_garden_demo.gd | scripts/demo/medieval_herb_garden_demo.gd | >> reference_mapping.md
echo | scripts/texture_shader_demo.gd | scripts/demo/texture_shader_demo.gd | >> reference_mapping.md
echo | scripts/setup_enhanced_cinematic.gd | scripts/demo/setup_enhanced_cinematic.gd | >> reference_mapping.md

echo.
echo Script reorganization completed successfully!
echo.
echo IMPORTANT: You will need to update script references in your project.
echo The reference mapping file has been updated with the new paths.
echo.
echo Press any key to exit...
pause > nul
