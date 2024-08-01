extends SceneTree

var Optparse = load('res://addons/gut/cli/optparse.gd')
var WarningsManager = load("res://addons/gut/warnings_manager.gd")

var godot_default_warnings = {
  "assert_always_false": 1,             "assert_always_true": 1,  			"confusable_identifier": 1,
  "confusable_local_declaration": 1,    "confusable_local_usage": 1,  		"constant_used_as_function": 1,
  "deprecated_keyword": 1,              "empty_file": 1,  					"enable": true,
  "exclude_addons": true, 				"function_used_as_property": 1,  	"get_node_default_without_onready": 2,
  "incompatible_ternary": 1,  			"inference_on_variant": 2,  		"inferred_declaration": 0,
  "int_as_enum_without_cast": 1,  		"int_as_enum_without_match": 1,  	"integer_division": 1,
  "narrowing_conversion": 1,  			"native_method_override": 2,  		"onready_with_export": 2,
  "property_used_as_function": 1,  		"redundant_await": 1,  				"redundant_static_unload": 1,
  "renamed_in_godot_4_hint": 1,  		"return_value_discarded": 0,  		"shadowed_global_identifier": 1,
  "shadowed_variable": 1,  				"shadowed_variable_base_class": 1,  "standalone_expression": 1,
  "standalone_ternary": 1,  			"static_called_on_instance": 1,  	"unassigned_variable": 1,
  "unassigned_variable_op_assign": 1,  	"unreachable_code": 1,  			"unreachable_pattern": 1,
  "unsafe_call_argument": 0,  			"unsafe_cast": 0,  					"unsafe_method_access": 0,
  "unsafe_property_access": 0,  		"unsafe_void_return": 1,  			"untyped_declaration": 0,
  "unused_local_constant": 1,  			"unused_parameter": 1,  			"unused_private_class_variable": 1,
  "unused_signal": 1,  					"unused_variable": 1
}

var gut_warning_changes = {
  "exclude_addons": false, 				"redundant_await": 0,
}

var warning_settings = {}

func _setup_warning_settings():
	warning_settings["godot_default"] = godot_default_warnings

	var gut_default = godot_default_warnings.duplicate()
	gut_default.merge(gut_warning_changes, true)
	warning_settings["gut_default"] = gut_default


func _print_human_readable(warnings):
	for key in warnings:
		var value = warnings[key]
		var readable = str(warnings[key]).capitalize()
		if(typeof(value) == TYPE_INT):
			readable = WarningsManager.WARNING_LOOKUP.get(value, str(readable, ' ???'))
			readable = readable.capitalize()
		print(key.capitalize().rpad(35, ' '), readable)


func _dump_settings(which):
	if(which == "current"):
		var values = WarningsManager.create_warnings_dictionary_from_project_settings()
		GutUtils.pretty_print(values)
	elif(warning_settings.has(which)):
		GutUtils.pretty_print(warning_settings[which])
	else:
		print("UNKNOWN print option ", which)


func _print_settings(which):
	if(which == "current"):
		var warnings = WarningsManager.create_warnings_dictionary_from_project_settings()
		_print_human_readable(warnings)
	elif(warning_settings.has(which)):
		_print_human_readable(warning_settings[which])
	else:
		print("UNKNOWN print option ", which)


func _set_settings(which):
	var warnings = {}

	if(which == 'all_warn'):
		warnings = WarningsManager.create_warn_all_warnings_dictionary()
		warnings.exclude_addons = false
	elif(warning_settings.has(which)):
		warnings = warning_settings[which]

	if(warnings != {}):
		WarningsManager.apply_warnings_dictionary(warnings)
		ProjectSettings.save()
		print("-- Values have been updated to --")
		_print_settings("current")
		print()
		print("Changes will not be visible in Godot until it is restarted.")
		print("Even if it asks you to reload...Maybe")
	else:
		print("UNKNOWN set option ", which)


func _setup_options():
	var opts = Optparse.new()
	opts.banner = """
	This is the banner!  Remember to use -- or ++ before these options or they
	don't work...but you saw this so you rememberd.  Good job.
	""".dedent()

	opts.add('-h', false, 'Print this help')
	opts.add('-dump', 'none', """Prints a dictionary of all warning values.  Valid values are:
		* current
		* godot_default
		* gut_default""".dedent())
	opts.add('-print', 'none', """Print human readable warning values.  Valid values are:
		* current
		* godot_default
		* gut_default""".dedent())
	opts.add('-set', 'none', """Sets the values for the project.  Valid values are:
		* godot_default
		* gut_default
		* all_warn""".dedent())

	return opts


func _init():
	_setup_warning_settings()

	var opts = _setup_options()
	opts.parse()

	if(opts.unused.size() != 0):
		opts.print_help()
		print("Unknown arguments ", opts.unused)
	if(opts.values.h):
		opts.print_help()
	elif(opts.values.print != 'none'):
		_print_settings(opts.values.print)
	elif(opts.values.dump != 'none'):
		_dump_settings(opts.values.dump)
	elif(opts.values.set != 'none'):
		_set_settings(opts.values.set)
	else:
		opts.print_help()
		print("You didn't specify any options.  I don't know what you want to do.")

	quit()