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


func test_orphans_made_in_test_cause_failure():
	var src = """
	func test_the_test():
		var n = make_node('test_the_test')
		assert_no_new_orphans()
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 1, 0)
	_free_orphans()


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


# Orphans are "counted" at the end of a test to generate output, so they will
# not appear in after_all as uncounted.
func test_non_asserted_orphans_not_found_in_after_all():
	var src = """
	func after_all():
		assert_no_new_orphans()

	func test_the_test():
		make_node('test_the_test')
		pass_test('this is passing')
	"""
	var t = await _run_test_script_source(src, _gut)
	assert_total_fail_pass(t, 0, 2)
	assert_total_orphans_recorded(_gut, 1)
	_free_orphans()


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


# I thought it would work the other way, but it works this way, so here is a
# test that just verifies how it works.  IDK if it SHOULD work the other way
# or not.
func test_orphans_made_in_after_each_are_not_found_in_after_all():
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
	assert_total_fail_pass(t, 0, 2)
	assert_total_orphans_recorded(_gut, 2)
	_free_orphans()
