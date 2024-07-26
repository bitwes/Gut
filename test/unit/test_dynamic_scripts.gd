extends GutInternalTester

const TAKE_OVER_PATH = "res://test/resources/take_over_this_path.gd"

func dyn_script(source, override_path=null):
	print(GutUtils.add_line_numbers(source.dedent()))
	var s = GutUtils.create_script_from_source(source, override_path)
	print(s.resource_path)
	return s


func test_make_one_that_extends_another():
	var s1 = dyn_script("""
	var foo = 'bar'

	func _get(prop):
		print("getting ", prop)

	func print_something():
		print("something")
	""", TAKE_OVER_PATH)
	# s1.take_over_path(TAKE_OVER_PATH)

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