extends SceneTree

var Optparse = load('res://addons/gut/cli/optparse.gd')
var WarningsManager = load("res://addons/gut/warnings_manager.gd")

# I used the tool to make the data for the tool.  I did change exclude_addons
# to be false, otherwise these warnings don't help.  Everything else is the
# default Godot setting as of the creation of this.
var default_wanrings = {
  "assert_always_false": 1,             "assert_always_true": 1,  			"confusable_identifier": 1,
  "confusable_local_declaration": 1,    "confusable_local_usage": 1,  		"constant_used_as_function": 1,
  "deprecated_keyword": 1,              "empty_file": 1,  					"enable": true,
  "exclude_addons": false, 				"function_used_as_property": 1,  	"get_node_default_without_onready": 2,
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


func _print_settings(which):
	if(which == "current"):
		var values = WarningsManager.create_warnings_dictionary_from_project_settings()
		print('-- Current Values --')
		GutUtils.pretty_print(values)
	elif(which == "default"):
		GutUtils.pretty_print(default_wanrings)
	else:
		print("UNKNOWN print option ", which)


func _set_settings(which):
	var warnings = {}

	if(which == 'default'):
		warnings = default_wanrings.duplicate()
	elif(which == 'all_warn'):
		warnings = WarningsManager.create_warn_all_warnings_dictionary()
		warnings.exclude_addons = false

	if(warnings != {}):
		WarningsManager.apply_warnings_dictionary(warnings)
		ProjectSettings.save()
		var set_values = WarningsManager.create_warnings_dictionary_from_project_settings()
		print("-- Values have been updated to --")
		GutUtils.pretty_print(set_values)
	else:
		print("UNKNOWN set option ", which)


func _setup_options():
	var opts = Optparse.new()
	opts.banner = """
	This is the banner!  Remember to use -- or ++ before these options or they
	don't work...but you saw this so you rememberd.  Good job.
	""".dedent()

	opts.add('-h', false, 'Print this help')
	opts.add('-print', 'none', """Print settings.  Valid values are:
		* current
		* default""".dedent())
	opts.add('-set', 'none', """Sets the values for the project.  Valid values are:
		* default
		* all_warn""".dedent())

	return opts


func _init():
	var opts = _setup_options()
	opts.parse()

	if(opts.get_value('-h')):
		opts.print_help()
	elif(opts.get_value('-print') != 'none'):
		_print_settings(opts.get_value('-print'))
	elif(opts.get_value('-set') != 'none'):
		_set_settings(opts.get_value('-set'))

	quit()