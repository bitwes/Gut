
const IGNORE = 0
const WARN = 1
const ERROR = 2


const WARNING_LOOKUP = {
	IGNORE : 'IGNORE',
	WARN : 'WARN',
	ERROR : 'ERROR'
}

const GDSCRIPT_WARNING = 'debug/gdscript/warnings/'


# ---------------------------------------
# Static
# ---------------------------------------

# This is static and set in _static_init so that we can get the current settings as
# soon as possible.
static var _project_warnings : Dictionary = {}
static var project_warnings := {} :
	get: return _project_warnings.duplicate()
	set(val): pass


static func _static_init():
	# print('---- warnings_manager.gd initialized ----')
	var wm = new()
	_project_warnings = wm.create_warnings_dictionary_from_project_settings()


## Turn all warnings on/off.  Use reset_warnings to restore the original value.
static func enable_warnings(should=true):
	ProjectSettings.set(str(GDSCRIPT_WARNING, 'enable'), should)


## Turn on/off excluding addons.  Use reset_warnings to restore the original value.
static func exclude_addons(should=true):
	ProjectSettings.set(str(GDSCRIPT_WARNING, 'exclude_addons'), should)


## Resets warning settings to what they are set to in Project Settings
static func reset_warnings():
	var wm = new()
	wm.apply_warnings_dictionary(_project_warnings)


# ---------------------------------------
# Class
# ---------------------------------------
func create_ignore_all_dictionary():
	return replace_warnings_values(project_warnings, -1, IGNORE)


func create_warn_all_warnings_dictionary():
	return replace_warnings_values(project_warnings, -1, WARN)


func replace_warnings_with_ignore(dict):
	return replace_warnings_values(dict, WARN, IGNORE)


func replace_errors_with_warnings(dict):
	return replace_warnings_values(dict, ERROR, WARN)


func replace_warnings_values(dict, replace_this, with_this):
	var to_return = dict.duplicate()
	for key in to_return:
		if(typeof(to_return[key]) == TYPE_INT and (replace_this == -1 or to_return[key] == replace_this)):
			to_return[key] = with_this
	return to_return


func create_warnings_dictionary_from_project_settings() -> Dictionary :
	var props = ProjectSettings.get_property_list()
	var to_return = {}
	for i in props.size():
		if(props[i].name.begins_with(GDSCRIPT_WARNING)):
			var prop_name = props[i].name.replace(GDSCRIPT_WARNING, '')
			to_return[prop_name] = ProjectSettings.get(props[i].name)
	return to_return


func set_project_setting_warning(warning_name : String, value : Variant):
	var property_name = str(GDSCRIPT_WARNING, warning_name)
	# This check will generate a warning if the setting does not exist
	if(property_name in ProjectSettings):
		ProjectSettings.set(property_name, value)


func apply_warnings_dictionary(warning_values : Dictionary):
	for key in warning_values:
		set_project_setting_warning(key, warning_values[key])


func print_warnings_dictionary(which : Dictionary):
	var is_valid = true
	for key in which:
		var value_str = str(which[key])
		if(_project_warnings.has(key)):
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




# func _set_all_project_settings_warnings(change_this : int, to_this : int):
# 	var current = create_project_warnings_dictionary()
# 	for key in current:
# 		if(typeof(current[key]) == TYPE_INT and (change_this == -1 or current[key] == change_this)):
# 			_set_project_setting(key, to_this)


# func set_all_warnings_to_ignore():
# 	_set_all_project_settings_warnings(WARN, IGNORE)


# func set_all_errors_to_warnings():
# 	_set_all_project_settings_warnings(ERROR, WARN)


# func set_all_to_ignore():
# 	_set_all_project_settings_warnings(-1, IGNORE)