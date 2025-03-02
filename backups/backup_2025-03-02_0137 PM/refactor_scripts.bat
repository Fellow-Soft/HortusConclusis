@echo off
echo Hortus Conclusus Code Refactoring
echo ===============================
echo.
echo This script will implement code refactoring improvements:
echo 1. Standardize naming conventions
echo 2. Consolidate helper functions
echo 3. Create a common utilities class
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul
echo.

REM Create backup of current scripts directory
echo Creating backup of scripts directory...
set backup_dir=backup_scripts_refactor_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%
mkdir %backup_dir%
xcopy /E /I /Y "scripts" "%backup_dir%\scripts"
echo Backup created in %backup_dir% directory.
echo.

REM Create version history file if it doesn't exist
echo Creating version history file...
if not exist "CHANGELOG.md" (
    echo # Hortus Conclusus Change Log > CHANGELOG.md
    echo. >> CHANGELOG.md
    echo This file tracks version history of the Hortus Conclusus project. >> CHANGELOG.md
    echo. >> CHANGELOG.md
    echo ## Version 1.0.0 ^(Current^) >> CHANGELOG.md
    echo. >> CHANGELOG.md
    echo ### Added >> CHANGELOG.md
    echo - Initial version with modular script organization >> CHANGELOG.md
    echo - Standardized naming conventions >> CHANGELOG.md
    echo - Consolidated helper functions >> CHANGELOG.md
    echo - Added common utilities class >> CHANGELOG.md
    echo. >> CHANGELOG.md
)

REM Create the common utilities class
echo Creating utilities.gd script...
echo "extends Node" > scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "class_name Utilities" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Constants" >> scripts\core\utilities.gd
echo "const UP_VECTOR = Vector3(0, 1, 0)" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Time of day enum" >> scripts\core\utilities.gd
echo "enum TimeOfDay {" >> scripts\core\utilities.gd
echo "    DAWN," >> scripts\core\utilities.gd
echo "    NOON," >> scripts\core\utilities.gd
echo "    DUSK," >> scripts\core\utilities.gd
echo "    NIGHT" >> scripts\core\utilities.gd
echo "}" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Meditation texts for different times of day" >> scripts\core\utilities.gd
echo "const MEDITATIONS = {" >> scripts\core\utilities.gd
echo "    \"dawn\": [" >> scripts\core\utilities.gd
echo "        \"As morning light filters through the mist,\"," >> scripts\core\utilities.gd
echo "        \"Sacred patterns emerge from darkness,\"," >> scripts\core\utilities.gd
echo "        \"The garden awakens to divine geometry,\"," >> scripts\core\utilities.gd
echo "        \"Each plant a symbol of celestial order.\"" >> scripts\core\utilities.gd
echo "    ]," >> scripts\core\utilities.gd
echo "    \"noon\": [" >> scripts\core\utilities.gd
echo "        \"In the fullness of day, the garden reveals its wisdom,\"," >> scripts\core\utilities.gd
echo "        \"Herbs arranged in patterns of the Trinity,\"," >> scripts\core\utilities.gd
echo "        \"Roses in five-fold symmetry honoring the Virgin,\"," >> scripts\core\utilities.gd
echo "        \"The cosmic order made manifest in living form.\"" >> scripts\core\utilities.gd
echo "    ]," >> scripts\core\utilities.gd
echo "    \"dusk\": [" >> scripts\core\utilities.gd
echo "        \"As shadows lengthen across the garden paths,\"," >> scripts\core\utilities.gd
echo "        \"The day's work completed in sacred harmony,\"," >> scripts\core\utilities.gd
echo "        \"Plants return their essence to the fading light,\"," >> scripts\core\utilities.gd
echo "        \"Preparing for night's contemplative silence.\"" >> scripts\core\utilities.gd
echo "    ]," >> scripts\core\utilities.gd
echo "    \"night\": [" >> scripts\core\utilities.gd
echo "        \"Under starlight, the garden dreams of eternity,\"," >> scripts\core\utilities.gd
echo "        \"Divine patterns continue their silent growth,\"," >> scripts\core\utilities.gd
echo "        \"In darkness, the soul finds its deepest truths,\"," >> scripts\core\utilities.gd
echo "        \"As above in the heavens, so below in the garden.\"" >> scripts\core\utilities.gd
echo "    ]" >> scripts\core\utilities.gd
echo "}" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Helper function to get up vector" >> scripts\core\utilities.gd
echo "static func get_up_vector() -> Vector3:" >> scripts\core\utilities.gd
echo "    return UP_VECTOR" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Convert time enum to string" >> scripts\core\utilities.gd
echo "static func time_enum_to_string(time: int) -> String:" >> scripts\core\utilities.gd
echo "    match time:" >> scripts\core\utilities.gd
echo "        TimeOfDay.DAWN:" >> scripts\core\utilities.gd
echo "            return \"dawn\"" >> scripts\core\utilities.gd
echo "        TimeOfDay.NOON:" >> scripts\core\utilities.gd
echo "            return \"noon\"" >> scripts\core\utilities.gd
echo "        TimeOfDay.DUSK:" >> scripts\core\utilities.gd
echo "            return \"dusk\"" >> scripts\core\utilities.gd
echo "        TimeOfDay.NIGHT:" >> scripts\core\utilities.gd
echo "            return \"night\"" >> scripts\core\utilities.gd
echo "    return \"dawn\"" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Convert time enum to float" >> scripts\core\utilities.gd
echo "static func time_enum_to_float(time: int) -> float:" >> scripts\core\utilities.gd
echo "    match time:" >> scripts\core\utilities.gd
echo "        TimeOfDay.DAWN:" >> scripts\core\utilities.gd
echo "            return 0.0" >> scripts\core\utilities.gd
echo "        TimeOfDay.NOON:" >> scripts\core\utilities.gd
echo "            return 0.25" >> scripts\core\utilities.gd
echo "        TimeOfDay.DUSK:" >> scripts\core\utilities.gd
echo "            return 0.5" >> scripts\core\utilities.gd
echo "        TimeOfDay.NIGHT:" >> scripts\core\utilities.gd
echo "            return 0.75" >> scripts\core\utilities.gd
echo "    return 0.0" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Convert float to time enum" >> scripts\core\utilities.gd
echo "static func float_to_time_enum(time_float: float) -> int:" >> scripts\core\utilities.gd
echo "    if time_float < 0.25:" >> scripts\core\utilities.gd
echo "        return TimeOfDay.DAWN" >> scripts\core\utilities.gd
echo "    elif time_float < 0.5:" >> scripts\core\utilities.gd
echo "        return TimeOfDay.NOON" >> scripts\core\utilities.gd
echo "    elif time_float < 0.75:" >> scripts\core\utilities.gd
echo "        return TimeOfDay.DUSK" >> scripts\core\utilities.gd
echo "    else:" >> scripts\core\utilities.gd
echo "        return TimeOfDay.NIGHT" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Interpolate between two time of day values" >> scripts\core\utilities.gd
echo "static func interpolate_time_of_day(from_time: int, to_time: int, factor: float) -> float:" >> scripts\core\utilities.gd
echo "    var from_float = time_enum_to_float(from_time)" >> scripts\core\utilities.gd
echo "    var to_float = time_enum_to_float(to_time)" >> scripts\core\utilities.gd
echo "    return lerp(from_float, to_float, factor)" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Fade transition helper" >> scripts\core\utilities.gd
echo "static func create_fade_transition(node: Node, property_path: String, from_value: float, to_value: float, duration: float) -> Tween:" >> scripts\core\utilities.gd
echo "    var tween = node.create_tween()" >> scripts\core\utilities.gd
echo "    tween.tween_property(node, property_path, to_value, duration)" >> scripts\core\utilities.gd
echo "    return tween" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Check if path exists in the project" >> scripts\core\utilities.gd
echo "static func resource_exists(path: String) -> bool:" >> scripts\core\utilities.gd
echo "    return ResourceLoader.exists(path)" >> scripts\core\utilities.gd
echo. >> scripts\core\utilities.gd
echo "# Create clean version of a string (remove spaces, special chars)" >> scripts\core\utilities.gd
echo "static func clean_string(text: String) -> String:" >> scripts\core\utilities.gd
echo "    var result = text.to_lower()" >> scripts\core\utilities.gd
echo "    result = result.replace(\" \", \"_\")" >> scripts\core\utilities.gd
echo "    result = result.replace(\"-\", \"_\")" >> scripts\core\utilities.gd
echo "    return result" >> scripts\core\utilities.gd

REM Standardize naming conventions
echo.
echo Standardizing naming conventions...

REM Create Python script to rename files
echo import os > rename_scripts.py
echo import re >> rename_scripts.py
echo import shutil >> rename_scripts.py
echo. >> rename_scripts.py
echo # Define the files to rename >> rename_scripts.py
echo files_to_rename = [ >> rename_scripts.py
echo     ('scripts/environment/atmosphere_controller_enhanced.gd', 'scripts/environment/atmosphere_controller.gd'), >> rename_scripts.py
echo     ('scripts/cinematic/cinematic_effects_enhanced.gd', 'scripts/cinematic/cinematic_effects.gd'), >> rename_scripts.py
echo     ('scripts/camera/camera_system_enhanced.gd', 'scripts/camera/camera_system.gd'), >> rename_scripts.py
echo     ('scripts/camera/camera_path_enhanced.gd', 'scripts/camera/camera_path.gd'), >> rename_scripts.py
echo     ('scripts/meditation/meditation_display_enhanced.gd', 'scripts/meditation/meditation_display.gd'), >> rename_scripts.py
echo     ('scripts/geometry/sacred_geometry_enhanced.gd', 'scripts/geometry/sacred_geometry.gd'), >> rename_scripts.py
echo     ('scripts/geometry/sacred_geometry_enhanced_helpers.gd', 'scripts/geometry/sacred_geometry_helpers.gd'), >> rename_scripts.py
echo     ('scripts/cinematic/hortus_conclusus_cinematic_complete.gd', 'scripts/cinematic/hortus_conclusus_cinematic.gd'), >> rename_scripts.py
echo ] >> rename_scripts.py
echo. >> rename_scripts.py
echo # Rename files >> rename_scripts.py
echo renamed_files = [] >> rename_scripts.py
echo for old_path, new_path in files_to_rename: >> rename_scripts.py
echo     if os.path.exists(old_path): >> rename_scripts.py
echo         try: >> rename_scripts.py
echo             shutil.copy2(old_path, new_path) >> rename_scripts.py
echo             renamed_files.append((old_path, new_path)) >> rename_scripts.py
echo             print(f"Renamed {old_path} to {new_path}") >> rename_scripts.py
echo         except Exception as e: >> rename_scripts.py
echo             print(f"Error renaming {old_path}: {e}") >> rename_scripts.py
echo. >> rename_scripts.py
echo # Update references in all script files >> rename_scripts.py
echo def update_file_references(file_path, renamed_files): >> rename_scripts.py
echo     try: >> rename_scripts.py
echo         with open(file_path, 'r', encoding='utf-8') as f: >> rename_scripts.py
echo             content = f.read() >> rename_scripts.py
echo. >> rename_scripts.py
echo         # Replace class references and preload paths >> rename_scripts.py
echo         for old_path, new_path in renamed_files: >> rename_scripts.py
echo             old_name = os.path.basename(old_path) >> rename_scripts.py
echo             new_name = os.path.basename(new_path) >> rename_scripts.py
echo             # Replace preload statements >> rename_scripts.py
echo             content = content.replace(f'preload("{old_path}")', f'preload("{new_path}")') >> rename_scripts.py
echo             content = content.replace(f"preload('{old_path}')", f"preload('{new_path}')") >> rename_scripts.py
echo             # Replace load statements >> rename_scripts.py
echo             content = content.replace(f'load("{old_path}")', f'load("{new_path}")') >> rename_scripts.py
echo             content = content.replace(f"load('{old_path}')", f"load('{new_path}')") >> rename_scripts.py
echo             # Replace class references (this assumes class names match file names) >> rename_scripts.py
echo             old_class = os.path.splitext(old_name)[0] >> rename_scripts.py
echo             new_class = os.path.splitext(new_name)[0] >> rename_scripts.py
echo             content = re.sub(r'\b' + re.escape(old_class) + r'\b', new_class, content) >> rename_scripts.py
echo. >> rename_scripts.py
echo         with open(file_path, 'w', encoding='utf-8') as f: >> rename_scripts.py
echo             f.write(content) >> rename_scripts.py
echo         return True >> rename_scripts.py
echo     except Exception as e: >> rename_scripts.py
echo         print(f"Error updating references in {file_path}: {e}") >> rename_scripts.py
echo         return False >> rename_scripts.py
echo. >> rename_scripts.py
echo # Update all script files >> rename_scripts.py
echo updated_files = 0 >> rename_scripts.py
echo for root, dirs, files in os.walk('scripts'): >> rename_scripts.py
echo     for file in files: >> rename_scripts.py
echo         if file.endswith('.gd'): >> rename_scripts.py
echo             file_path = os.path.join(root, file) >> rename_scripts.py
echo             if update_file_references(file_path, renamed_files): >> rename_scripts.py
echo                 updated_files += 1 >> rename_scripts.py
echo. >> rename_scripts.py
echo # Update reference mapping file >> rename_scripts.py
echo if os.path.exists('reference_mapping.md'): >> rename_scripts.py
echo     with open('reference_mapping.md', 'r', encoding='utf-8') as f: >> rename_scripts.py
echo         content = f.read() >> rename_scripts.py
echo. >> rename_scripts.py
echo     # Add standardized naming section >> rename_scripts.py
echo     if '## Standardized Naming' not in content: >> rename_scripts.py
echo         content += "\n\n## Standardized Naming\n\n" >> rename_scripts.py
echo         content += "| Original Enhanced Name | Standardized Name |\n" >> rename_scripts.py
echo         content += "| --------------------- | ---------------- |\n" >> rename_scripts.py
echo         for old_path, new_path in renamed_files: >> rename_scripts.py
echo             old_name = os.path.basename(old_path) >> rename_scripts.py
echo             new_name = os.path.basename(new_path) >> rename_scripts.py
echo             content += f"| {old_name} | {new_name} |\n" >> rename_scripts.py
echo. >> rename_scripts.py
echo     with open('reference_mapping.md', 'w', encoding='utf-8') as f: >> rename_scripts.py
echo         f.write(content) >> rename_scripts.py
echo. >> rename_scripts.py
echo print(f"\nRenamed {len(renamed_files)} files and updated references in {updated_files} files.") >> rename_scripts.py

REM Run the Python script
echo Running file renaming script...
python rename_scripts.py
del rename_scripts.py

REM Consolidate helper functions
echo.
echo Consolidating helper functions...

REM Create Python script to consolidate helper functions
echo import os > consolidate_helpers.py
echo import re >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo def merge_sacred_geometry_helpers(): >> consolidate_helpers.py
echo     # Get the paths >> consolidate_helpers.py
echo     main_file = 'scripts/geometry/sacred_geometry.gd' >> consolidate_helpers.py
echo     helper_file = 'scripts/geometry/sacred_geometry_helpers.gd' >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo     # Check if both files exist >> consolidate_helpers.py
echo     if not os.path.exists(main_file) or not os.path.exists(helper_file): >> consolidate_helpers.py
echo         print(f"Either {main_file} or {helper_file} does not exist.") >> consolidate_helpers.py
echo         return False >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo     # Read both files >> consolidate_helpers.py
echo     with open(main_file, 'r', encoding='utf-8') as f: >> consolidate_helpers.py
echo         main_content = f.read() >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo     with open(helper_file, 'r', encoding='utf-8') as f: >> consolidate_helpers.py
echo         helper_content = f.read() >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo     # Extract methods from helper file >> consolidate_helpers.py
echo     helper_methods = re.findall(r'func\s+(\w+\(.*?\))([\s\S]*?)(?=\nfunc|\Z)', helper_content) >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo     # Find the end of the main file's content >> consolidate_helpers.py
echo     if helper_methods: >> consolidate_helpers.py
echo         # Add a section comment >> consolidate_helpers.py
echo         main_content += "\n\n# Helper Functions (Consolidated from sacred_geometry_helpers.gd)\n" >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo         # Add each helper method to the main file >> consolidate_helpers.py
echo         for method_signature, method_body in helper_methods: >> consolidate_helpers.py
echo             main_content += f"\nfunc {method_signature}{method_body}" >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo         # Write the combined content back to the main file >> consolidate_helpers.py
echo         with open(main_file, 'w', encoding='utf-8') as f: >> consolidate_helpers.py
echo             f.write(main_content) >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo         print(f"Successfully consolidated helper functions from {helper_file} into {main_file}.") >> consolidate_helpers.py
echo         return True >> consolidate_helpers.py
echo     else: >> consolidate_helpers.py
echo         print(f"No helper methods found in {helper_file}.") >> consolidate_helpers.py
echo         return False >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo # Execute the consolidation >> consolidate_helpers.py
echo success = merge_sacred_geometry_helpers() >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo # Update the project structure documentation >> consolidate_helpers.py
echo if success: >> consolidate_helpers.py
echo     project_structure_path = 'PROJECT_STRUCTURE.md' >> consolidate_helpers.py
echo     if os.path.exists(project_structure_path): >> consolidate_helpers.py
echo         with open(project_structure_path, 'r', encoding='utf-8') as f: >> consolidate_helpers.py
echo             content = f.read() >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo         # Update the sacred geometry entry >> consolidate_helpers.py
echo         content = content.replace('sacred_geometry_enhanced.gd', 'sacred_geometry.gd') >> consolidate_helpers.py
echo         content = content.replace('sacred_geometry_enhanced_helpers.gd', '(consolidated into sacred_geometry.gd)') >> consolidate_helpers.py
echo. >> consolidate_helpers.py
echo         with open(project_structure_path, 'w', encoding='utf-8') as f: >> consolidate_helpers.py
echo             f.write(content) >> consolidate_helpers.py

REM Run the Python script to consolidate helper functions
echo Running helper function consolidation script...
python consolidate_helpers.py
del consolidate_helpers.py

echo.
echo Code refactoring completed successfully!
echo.
echo The following improvements have been made:
echo 1. Created utilities.gd with common functions
echo 2. Standardized naming conventions by removing "enhanced" and "complete" suffixes
echo 3. Consolidated sacred_geometry_helpers.gd into sacred_geometry.gd
echo 4. Added version tracking in CHANGELOG.md
echo.
echo IMPORTANT: You may need to update scene references to the renamed scripts.
echo The reference_mapping.md file has been updated with the standardized names.
echo.
echo Press any key to exit...
pause > nul
