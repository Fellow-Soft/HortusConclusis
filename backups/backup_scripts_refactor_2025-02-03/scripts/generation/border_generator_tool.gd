@tool
extends EditorScript

# This is an editor script tool for generating illuminated manuscript border assets
# To run this, select the script in the FileSystem panel in Godot editor and click 
# "Run" in the editor toolbar. The assets will be generated in the illuminated_borders folder.

func _run():
    print("Generating illuminated manuscript borders...")
    
    # Call our border generator
    var BorderGen = load("res://scripts/generate_illuminated_borders.gd")
    
    # Generate the set of borders
    BorderGen.generate_border_set()
    
    print("Border generation complete!")
