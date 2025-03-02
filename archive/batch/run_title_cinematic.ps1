# PowerShell script to run the Hortus Conclusus cinematic with title screen
Write-Host "Starting Hortus Conclusus Cinematic Experience with Title Screen..." -ForegroundColor Green

# Get the path to Godot executable
$godotPath = "C:\Users\joshu\Godot\godot.exe"

# If the default path doesn't exist, try to find Godot in common locations
if (-not (Test-Path $godotPath)) {
    $godotPath = "godot.exe" # Try using godot from PATH
}

# Run the cinematic scene with our title screen script
& $godotPath --path "$PSScriptRoot" --scene "scenes/hortus_conclusus_cinematic.tscn" --script "scripts/hortus_conclusus_cinematic_new.gd"

Write-Host "Cinematic experience completed." -ForegroundColor Green
