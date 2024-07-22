extends GutInternalTester

# class DynamicGutTest:
# 	var logger = GutUtils.get_logger()
# 	var source_entries = []

# 	func _init(lgr=null):
# 		if(lgr != null):
# 			logger = lgr

# 	func _unindent(source, min_indent=0):
# 		var src = ""
# 		var lines = source.split("\n")

# 		var first_line_with_text_index = 0
# 		while(lines[first_line_with_text_index] == ""):
# 			first_line_with_text_index += 1

# 		var tab_count = 0
# 		while(lines[first_line_with_text_index].begins_with("\t")):
# 			tab_count += 1
# 			lines[first_line_with_text_index] = lines[first_line_with_text_index].trim_prefix("\t")


# 		while(lines[lines.size() -1].strip_edges() == ""):
# 			lines.remove_at(lines.size() -1)

# 		var to_remove = "\t".repeat(tab_count)
# 		var to_add = "\t".repeat(min_indent)
# 		for line in lines:
# 			src += str("\n", to_add, line.trim_prefix(to_remove))

# 		return src


# 	func make_source():
# 		var src = "extends GutTest\n"
# 		for e in source_entries:
# 			src += str(e, "\n")

# 		return src


# 	func make_script():
# 		return GutUtils.create_script_from_source(make_source())


# 	func make_new():
# 		var n = make_script().new()
# 		n.set_logger(logger)
# 		return n


# 	func add_source(p1='', p2='', p3='', p4='', p5='', p6='', p7='', p8='', p9='', p10=''):
# 		var source = str(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
# 		source_entries.append(_unindent(source))
# 		return self


# 	func add_as_test_to_gut(which):
# 		var dyn = make_script()
# 		which.get_test_collector().add_script(dyn.resource_path)


# 	func run_test_in_gut(which):
# 		add_as_test_to_gut(which)
# 		which.run_tests()
# 		var s = GutUtils.Summary.new()
# 		return s.get_totals(which)




var _gut = null


func _run_test_source(dyn_script):
	dyn_script.add_as_test_to_gut(_gut)
	_gut.run_tests()
	var s = GutUtils.Summary.new()
	return s.get_totals(_gut)


func before_all():
	verbose = true


func before_each():
	_gut = new_gut(verbose)
	add_child_autofree(_gut)


func test_stubbing_dynamic_script():
	var dyn_script = DynamicGutTest.new()
	dyn_script.add_source("""
		func test_stub_to_pass():
			fail_test("this just fails")
	""")
	var result = _run_test_source(dyn_script)
	assert_eq(result.failing, 1)


func test_stubbing_dynamic_script_2():
	var dyn_script = DynamicGutTest.new()
	dyn_script.add_source("""
	func test_stub_to_pass():
		pass_test("This just passes")
	""")
	var result = _run_test_source(dyn_script)
	assert_eq(result.passing, 1)


var my_lambda = func():
	print("------- HELLO WORLD -------")
	return 8

func test_more_dynamic():
	var dyn_script = DynamicGutTest.new()
	dyn_script.add_source("var lambda = instance_from_id(", get_instance_id(), ").my_lambda")
	dyn_script.add_source("""
	func test_stub_to_pass():
		assert_eq(lambda.call(), 8)
	""")
	var result = _run_test_source(dyn_script)
	assert_eq(result.passing, 1)


func test_even_more_dynmaic():
	var dyn_script = DynamicGutTest.new()
	var l = func(t):
		t.assert_true(true, "this should be true...but is it?")
		print("-------- fooooooooo --------")
	dyn_script.add_lambda_test(l)
	var result = _run_test_source(dyn_script)
	assert_eq(result.passing, 1)


func test_even_more_dynmaic_just_run_test():
	var dyn_script = DynamicGutTest.new()
	var l = func(t, x, y, z):
		print("---", x, "::", y, "::", z, "---")
		t.assert_eq(x, 1, "x should be 1")
		t.assert_eq(y, 2, "y should bd 2")
		print("-------- BAAAAAAARRRR --------")
	dyn_script.add_lambda_test(l.bind(1, 2, 3), "test_call_it_this")
	var inst = dyn_script.make_new()
	inst.test_call_it_this()
	assert_pass(inst, 2)


func test_running_the_test():
	var dyn_script = DynamicGutTest.new()
	var d = dyn_script.add_source("""
	func test_stub_to_pass():
		assert_false(true)
	""").make_new()
	autofree(d)
	d.test_stub_to_pass()
	assert_eq(d.get_fail_count(), 1)
	# var result = _run_test_source(dyn_script)
	# assert_eq(result.passing, 1)
