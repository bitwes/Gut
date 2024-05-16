var default_script_name_no_extension = 'gut_dynamic_script'
var default_script_resource_path = 'res://addons/gut/not_a_real_file/'

var _created_script_count = 0

func create_script_from_source(source, override_path=null):
	_created_script_count += 1
	var r_path = str(default_script_resource_path, default_script_name_no_extension, '_', _created_script_count)
	if(override_path != null):
		r_path = override_path

	var DynamicScript = GDScript.new()
	DynamicScript.source_code = source
	# The resource_path must be unique or Godot thinks it is trying
	# to load something it has already loaded and generates an error like
	# ERROR: Another resource is loaded from path 'workaround for godot issue #65263' (possible cyclic resource inclusion).
	DynamicScript.resource_path = r_path
	var result = DynamicScript.reload()
	if(result != OK):
		DynamicScript = result

	return DynamicScript

