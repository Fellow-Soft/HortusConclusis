extends Node

# This script provides a global handler for the up vector
# It's designed to be autoloaded and accessed from anywhere

# The constant up vector
const UP_VECTOR = Vector3(0, 1, 0)

# Get the up vector
static func get_up_vector() -> Vector3:
    return UP_VECTOR

# This function is called by other scripts that need the up vector
static func up() -> Vector3:
    return UP_VECTOR
