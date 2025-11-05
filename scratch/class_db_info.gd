extends SceneTree

var ThingCounter = load('res://addons/gut/thing_counter.gd')
var ObjectInspector = load('res://scratch/object_inspector.gd')
# SCRIPT ERROR: Parse Error: Identifier "GDScriptNativeClass" not declared in the current scope.
# SCRIPT ERROR: Parse Error: Identifier "SceneCacheInterface" not declared in the current scope.
# SCRIPT ERROR: Parse Error: Identifier "SceneRPCInterface" not declared in the current scope.
# SCRIPT ERROR: Parse Error: Identifier "SceneReplicationInterface" not declared in the current scope.
# SCRIPT ERROR: Parse Error: Identifier "ThemeContext" not declared in the current scope.



func search_for_enum(name):
	var classes = ClassDB.get_class_list()
	var found = false
	for c in classes:
		if(ClassDB.class_has_enum(c, name)):
			print(c, ' has ', name)
			found = true

	if(!found):
		print('could not find enum ', name)


func get_all_enums():
	var classes = ClassDB.get_class_list()
	var found = false
	var enums = ThingCounter.new()
	for c in classes:
		var class_enums = ClassDB.class_get_enum_list(c)
		for e in class_enums:
			enums.add(e)
			var enum_constants = ClassDB.class_get_enum_constants(c, e)
			print(e)
			print('    ', enum_constants)
			print()


func get_all_int_constants():
	var classes = ClassDB.get_class_list()
	var found = false
	var all_int_consts = ThingCounter.new()
	for c in classes:
		var int_consts = ClassDB.class_get_integer_constant_list(c)
		# print(c, ':')
		# print('    ', int_consts)
		for ic in int_consts:
			all_int_consts.add(ic)

	print(all_int_consts.to_s())


func get_all_properties():
	var classes = ClassDB.get_class_list()
	var all_properties = ThingCounter.new()
	for c in classes:
		var prop_list = ClassDB.class_get_property_list(c)
		for p in prop_list:
			all_properties.add(p.name)

	print(all_properties.to_s())


func print_all_classes():
	var classes = ClassDB.get_class_list()

	for c in classes:
		print(c)

func _print_call_class_db_method(method_name, on_class):
	var result = ClassDB.call(method_name, on_class)
	print(method_name, ':  ', result)

func print_whats_up_with_these_guys():
	var oi = ObjectInspector.ClassDBInspector.new()
	var these_guys = [
		"GDScriptNativeClass",
		"SceneCacheInterface",
		"SceneRPCInterface",
		"SceneReplicationInterface",
		"ThemeContext",

		"Input"
	]
	for classname in these_guys:
		print("---- ", classname, " ----")
		_print_call_class_db_method("get_parent_class", classname)
		_print_call_class_db_method("can_instantiate", classname)
		_print_call_class_db_method("is_class_enabled", classname)
		_print_call_class_db_method("class_exists", classname)
		_print_call_class_db_method("class_get_api_type", classname)
		oi.print_method_signatures(classname)

		print()

func _init():
	# get_all_enums()
	# get_all_int_constants()
	# get_all_properties()
	# print_all_classes()
	print_whats_up_with_these_guys()

	quit()