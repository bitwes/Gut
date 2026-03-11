extends GutInternalTester

var _gut = null
var _base_src = """
func make_node(node_name):
	var n = Node.new()
	n.name = node_name
	return n
"""

func before_all():
	verbose = true


func before_each():
	_gut = add_child_autofree(new_gut(verbose))
	var l = _gut.get_logger()
	l.set_type_enabled(l.types.orphan, verbose)
	if(!verbose):
		_gut.log_level = 0


func _free_orphans():
	var ids = Node.get_orphan_node_ids()
	for id in ids:
		if(is_instance_id_valid(id)):
			var n = instance_from_id(id)
			n.free()


func _run_test_script_source(src, g):
	var s = autofree(DynamicGutTest.new())
	s.add_source(_base_src)
	s.add_source(src)
	return await s.run_tests_in_gut_await(g)


func assert_total_orphans_recorded(g, count):
	var oc = g.get_orphan_counter()
	var ids = oc.get_orphan_ids()
	assert_eq(ids.size(), count, "Recorded orphan count")


func assert_total_fail_pass(totals, fail_count, pass_count):
	assert_eq(totals.failing, fail_count, 'Expected fail count')
	assert_eq(totals.passing, pass_count, 'Expected pass count')


# --------------------------
# Test related counts
# --------------------------
func test_orphans_made_in_test_cause_failure():
	var src = """
	func test_the_test():
		var n = make_node('test_the_test')
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 0)
	_free_orphans()


func test_script_level_orphans_do_not_appear_as_test_orphans():
	var src = """
	var n = make_node('script_level')

	func test_the_test():
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 0, 1)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


func test_orphans_are_not_counted_twice_in_a_test():
	var src = """
	func test_the_test():
		make_node('made_an_orphan')
		assert_no_new_orphans()
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


func test_orphans_no_orphans_then_orphans_again_in_a_test():
	var src = """
	func test_the_test():
		make_node('made_an_orphan')
		assert_no_new_orphans()

		assert_no_new_orphans()

		make_node('made_an_orphan')
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 2, 1)
	assert_total_orphans_recorded(_gut, 2)
	_free_orphans()


# --------------------------
# after_all
# --------------------------
func test_checking_for_orphans_in_after_all_is_ok():
	var src = """
	func after_all():
		assert_no_new_orphans()

	func test_the_test():
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 0, 2)


func test_orphans_made_after_test_found_in_after_all():
	var src = """
	func after_all():
		await wait_frames(10)
		assert_no_new_orphans()

	func test_the_test():
		make_node.call_deferred('test_the_test')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 0)
	_free_orphans()


func test_orphans_made_in_after_all_are_found_in_after_all():
	var src = """
	func after_all():
		make_node('made_in_after_all')
		assert_no_new_orphans()

	func test_the_test():
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	_free_orphans()


func test_non_asserted_orphans_are_found_in_after_all():
	var src = """
	func after_all():
		assert_no_new_orphans()

	func test_the_test():
		make_node('test_the_test')
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


func test_asserted_orphans_are_found_in_after_all():
	var src = """
	func after_all():
		assert_no_new_orphans()

	func test_the_test():
		make_node('test_the_test')
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 2, 0)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


func test_orphans_made_in_after_each_are_found_in_after_all():
	var src = """
	func after_all():
		assert_no_new_orphans()

	func after_each():
		make_node('test_the_test')

	func test_the_test():
		make_node('test_the_test')
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 2)
	_free_orphans()


func test_script_level_orphans_found_in_after_all():
	var src = """
	var n = make_node('script_level')

	func after_all():
		assert_no_new_orphans('after_all')
		gut.get_orphan_counter().log_all()

	func test_the_test():
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


func test_orphans_no_orphans_then_orphans_again_in_a_test_then_after_all():
	var src = """
	func after_all():
		assert_no_new_orphans()

	func test_the_test():
		make_node('made_an_orphan')
		assert_no_new_orphans()

		assert_no_new_orphans()

		make_node('made_an_orphan')
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 3, 1)
	assert_total_orphans_recorded(_gut, 2)
	_free_orphans()


func test_freed_orphans_do_not_cause_failure_in_after_all():
	var src = """
	var n = null
	func after_all():
		assert_no_new_orphans()

	func after_each():
		n.free()

	func test_the_test():
		n = make_node('made_an_orphan')
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 0)
	_free_orphans()


# --------------------------
# after_each
# --------------------------
func test_non_asserted_orphans_are_found_in_after_each():
	var src = """
	func after_each():
		assert_no_new_orphans()

	func test_the_test():
		make_node('test_the_test')
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


# --------------------------
# before_all
# --------------------------
func test_script_level_orphans_found_in_before_all():
	var src = """
	var n = make_node('script_level')

	func before_all():
		assert_no_new_orphans()

	func test_the_test():
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 1)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


