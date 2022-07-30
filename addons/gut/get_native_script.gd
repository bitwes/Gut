# Since NativeExtension does not exist if GDExtension is not included in the build
# of Godot this script is conditionally loaded only when NativeExtension exists.
# You can then get a reference to NativeExtension for use in `is` checks by calling
# get_it.
static func get_it():
	return NativeExtension
