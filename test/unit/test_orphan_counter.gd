extends GutInternalTester

func test_can_make_one():
	assert_not_null(GutUtils.OrphanCounter.new())


class TestOrphanIds:
	extends GutInternalTester

	var new_orphans = []

	func new_primed_orphan_counter():
		var oc = partial_double(GutUtils.OrphanCounter).new()
		# record everything that already exists, root is sometimes in
		# the list?
		oc.record_orphans('none')
		return oc


	func test_recording_orphans_returns_instance_ids():
		var oc = new_primed_orphan_counter()
		var n1 = autofree(Node.new())
		var orphans = oc.record_orphans('test_group')
		assert_eq(orphans, [n1.get_instance_id()])


	func test_can_get_orphans_by_group():
		var oc = new_primed_orphan_counter()
		var n1 = autofree(Node.new())
		var n2 = autofree(Node.new())
		oc.record_orphans('test_group')
		var results = oc.get_orphan_ids('test_group')
		results = oc.convert_instance_ids_to_valid_instances(results)
		results.sort()
		assert_true(results.all(func(e):
			return [n1, n2].has(e)))


	func test_can_get_orphans_by_group_and_subgroup():
		var oc = new_primed_orphan_counter()
		var n1 = autofree(Node.new())
		var n2 = autofree(Node.new())
		oc.record_orphans('group', 'subgroup')
		var results = oc.get_orphan_ids('group', 'subgroup')
		results = oc.convert_instance_ids_to_valid_instances(results)
		results.sort()
		assert_true(results.all(func(e):
			return [n1, n2].has(e)))


	func test_can_get_all_subgroup_oprhans_using_group():
		var oc = new_primed_orphan_counter()
		var n1 = autofree(Node.new())
		var n2 = autofree(Node.new())
		oc.record_orphans('group', 'subgroup')
		var result = oc.get_orphan_ids("group")
		assert_eq(result.size(), 2)

