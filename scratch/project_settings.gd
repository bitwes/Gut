extends SceneTree

const GDSCRIPT_WARNING = 'debug/gdscript/warnings/'

func _print_property(prop, thing, print_all_meta=false):
	var prop_name = prop.name
	var prop_value = thing.get(prop.name)
	var print_value = str(prop_value)
	if(print_value.length() > 100):
		print_value = print_value.substr(0, 97) + '...'
	elif(print_value == ''):
		print_value = 'EMPTY'

	print(prop_name, ' = ', print_value)
	if(print_all_meta):
		print('  ', prop)


func print_properties(props, thing, print_all_meta=false):
	for i in range(props.size()):
		_print_property(props[i], thing, print_all_meta)



# debug/gdscript/warnings/native_method_override = 1
func print_project_settings():
	print(ProjectSettings)
	print_properties(ProjectSettings.get_property_list(), ProjectSettings)


func print_gdscript_warnings():
	var props = ProjectSettings.get_property_list()
	for i in range(props.size()):
		if(props[i].name.begins_with(GDSCRIPT_WARNING)):
			_print_property(props[i], ProjectSettings, false)


func _init():
	# print_project_settings()
	print_gdscript_warnings()
	quit()