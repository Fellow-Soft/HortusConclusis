import os 
import re 
 
def merge_sacred_geometry_helpers(): 
    # Get the paths 
    main_file = 'scripts/geometry/sacred_geometry.gd' 
    helper_file = 'scripts/geometry/sacred_geometry_helpers.gd' 
 
    # Check if both files exist 
    if not os.path.exists(main_file) or not os.path.exists(helper_file): 
        print(f"Either {main_file} or {helper_file} does not exist.") 
        return False 
 
    # Read both files 
    with open(main_file, 'r', encoding='utf-8') as f: 
        main_content = f.read() 
 
    with open(helper_file, 'r', encoding='utf-8') as f: 
        helper_content = f.read() 
 
    # Extract methods from helper file 
