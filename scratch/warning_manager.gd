extends SceneTree

const IGNORE = 0
const WARN = 1
const ERROR = 2


const WARNING_LOOKUP = {
	IGNORE : 'IGNORE',
	WARN : 'WARN',
	ERROR : 'ERROR'
}

const GDSCRIPT_WARNING = 'debug/gdscript/warnings/'

class GdscriptWarningManager:
	var _project_levels = create_warnings_dictionary()
	var project_levels = _project_levels :
		get:
			return _project_levels.duplicate()
		set(val):
			push_error('project_levels is read only.')

	func _set_project_setting(warning_name, value):
		var property_name = str(GDSCRIPT_WARNING, warning_name)
		# This check will generate a warning if the setting does not exist
		if(property_name in ProjectSettings):
			ProjectSettings.set(property_name, value)


	func apply_warnings_dictionary(warning_values):
		for key in warning_values:
			_set_project_setting(key, warning_values[key])


	func reset():
		apply_warnings_dictionary(_project_levels)


	func create_warnings_dictionary():
		var props = ProjectSettings.get_property_list()
		var to_return = {}
		for i in props.size():
			if(props[i].name.begins_with(GDSCRIPT_WARNING)):
				var prop_name = props[i].name.replace(GDSCRIPT_WARNING, '')
				to_return[prop_name] = ProjectSettings.get(props[i].name)
		return to_return


	func print_warnings_dictionary(which):
		var is_valid = true
		for key in which:
			var value_str = str(which[key])
			if(_project_levels.has(key)):
				if(typeof(which[key]) == TYPE_INT):
					if(WARNING_LOOKUP.has(which[key])):
						value_str = WARNING_LOOKUP[which[key]]
					else:
						push_warning(str(which[key], ' is not a valid value for ', key))
						is_valid = false
			else:
				push_warning(str(key, ' is not a valid warning setting'))
				is_valid = false
			var s = str(key, ' = ', value_str)
			print(s)
		return is_valid


	func print_current_values():
		var current = create_warnings_dictionary()
		print(current)
		print_warnings_dictionary(current)


	func _set_all(change_this, to_this):
		var current = create_warnings_dictionary()
		for key in current:
			if(typeof(current[key]) == TYPE_INT and (change_this == -1 or current[key] == change_this)):
				_set_project_setting(key, to_this)



	func set_all_warnings_to_ignore():
		_set_all(WARN, IGNORE)


	func set_all_errors_to_warnings():
		_set_all(ERROR, WARN)


	func set_all_to_ignore():
		_set_all(-1, IGNORE)


func _test_it_all_out():
	var gwm = GdscriptWarningManager.new()
	var test_dict = gwm.create_warnings_dictionary()
	test_dict.native_method_override = 0
	test_dict.foo = 0
	test_dict.onready_with_export = 9
	gwm.apply_warnings_dictionary(test_dict)
	gwm.print_warnings_dictionary(test_dict)
	gwm.set_all_errors_to_warnings()
	gwm.set_all_warnings_to_ignore()
	print("\n\n")
	gwm.print_current_values()
	# gwm.print_warning_dictionary(test_dict)


func _init():
	var gwm = GdscriptWarningManager.new()
	var opts = gwm.create_warnings_dictionary()

	print("ignore")
	opts.exclude_addons = false
	opts.native_method_override = IGNORE
	gwm.apply_warnings_dictionary(opts)
	var dblr = load("res://addons/gut/doubler.gd")

	print("error")
	opts.native_method_override = ERROR
	gwm.apply_warnings_dictionary(opts)
	dblr.reload()

	print("warn")
	opts.native_method_override = WARN
	gwm.apply_warnings_dictionary(opts)
	dblr.reload()

	print("done")
	quit()