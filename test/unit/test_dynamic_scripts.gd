extends GutInternalTester


class CustomScriptLoader:
	extends ResourceFormatLoader

	var paths_and_source = {}

	var _extensions : PackedStringArray = ["gutgd"]

	func _print_params(method_name, params):
		print(method_name, "(", ", ".join(params), ")")

	func _exists(path):
		_print_params("_exists", [path])
		return true

	# func _get_dependencies(path, add_types):
	# 	_print_params("_get_dependencies", [path, add_types])
	# 	return PackedStringArray(["Resource"])

	func _get_recognized_extensions():
		print('_get_recognized_extensions')
		return _extensions.duplicate()

	# func _get_resource_script_class(path):
	# 	_print_params("_get_resource_script_class", [path])
	# 	return "Resource"

	# func _get_resource_type(path):
	# 	_print_params("_get_resource_type", [path])
	# 	return "Resource"

	# func _get_resource_uid(path):
	# 	_print_params("_get_resource_uid", [path])
	# 	return "asdfasdf"

	# func _handles_type(type):
	# 	_print_params("_handles_types", [type])
	# 	return true

	func _load(path, original_path, use_sub_threads, cache_mode):
		var source = """
		extends Button
		func print_something():
			print("hello world")
		"""

		if(paths_and_source.has(path)):
			source = paths_and_source[path]

		_print_params("_load", [path, original_path, use_sub_threads, cache_mode])
		return GutUtils.create_script_from_source(source)

	# func _recognize_path(path, type):
	# 	_print_params("_recognize_path", [path, type])
	# 	return true



const TAKE_OVER_PATH = "res://test/resources/take_over_this_path.gd"

var dyn_script_maker = load("res://addons/gut/dynamic_gdscript.gd").new()
var custom_loader = CustomScriptLoader.new()

func before_all():
	dyn_script_maker.default_script_extension = "gutgd"
	ResourceLoader.add_resource_format_loader(custom_loader, true)

func after_all():
	ResourceLoader.remove_resource_format_loader(custom_loader)

func dyn_script(source, override_path=null):
	print(GutUtils.add_line_numbers(source.dedent()))
	var s = dyn_script_maker.create_script_from_source(source, override_path)
	print(s.resource_path)
	return s


func _test_make_one_that_extends_another():
	var s1 = dyn_script("""
	var foo = 'bar'

	func _get(prop):
		print("getting ", prop)

	func print_something():
		print("something")
	""")

	var s1_inst = s1.new()
	s1_inst.print_something()

	var s2 = dyn_script(str(
		"extends '", s1.resource_path, "'\n",
		"func print_something():\n",
		# "	super.print_something()\n",
		"	print(\"something else\")"
	))

	var inst = s2.new()
	print(inst.foo)
	assert_not_null(s2)
	assert_eq(inst.foo, 'bar')
	inst.print_something()


func test_taking_over_path_works_with_new_base_type():
	var s = dyn_script("""
	extends Node2D

	func do_this():
		print("did it")
	""")
	var inst = autofree(s.new())
	assert_is(inst, Node2D)


	var s2 = dyn_script("""
	extends Node2D

	func do_this():
		print("did it")
	""", s.resource_path)


func test_whatever_this_is():
	custom_loader.paths_and_source["res://dne.gutgd"] = """
	func what_you_talking_about_willis():
		print("crazy eyed stare")
	"""

	var DynScript = load("res://dne.gutgd")
	print(DynScript)
	var inst = DynScript.new()
	print(inst)
	inst.what_you_talking_about_willis()


	custom_loader.paths_and_source["res://dne.gutgd"] = """
	func what_you_talking_about_willis():
		print("shiiiiiiiit")
	"""

	DynScript = load("res://dne.gutgd")
	print(DynScript)
	inst = DynScript.new()
	print(inst)
	inst.what_you_talking_about_willis()


func requires_button(btn : Button):
	print(btn)

func test_faking_as():
	var s1 = dyn_script("""
	extends Button

	func do_this():
		print("did it")
	""")

	var inst = s1.new()
	requires_button(inst as Button)


