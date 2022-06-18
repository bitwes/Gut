extends 'res://test/gut_test.gd'

func test_can_make_one():
	assert_not_null(_utils.OrphanCounter.new())

func test_can_add_get_counter():
	var oc = partial_double(_utils.OrphanCounter).new()
	stub(oc, 'orphan_count').to_return(6)
	oc.add_counter('one')
	stub(oc, 'orphan_count').to_return(10)
	assert_eq(oc.get_counter('one'), 4)

func test_print_singular_orphan():
	stub(_utils.Logger, '_init').to_do_nothing()
	var oc = partial_double(_utils.OrphanCounter).new()
	var d_logger = double(_utils.Logger).new()

	stub(oc, 'orphan_count').to_return(1)
	oc.add_counter('one')
	stub(oc, 'orphan_count').to_return(2)
	oc.print_orphans('one', d_logger)
	var msg = get_call_parameters(d_logger, 'orphan')[0]
	assert_string_contains(msg, 'orphan(')

func test_print_plural_orphans():
	stub(_utils.Logger, '_init').to_do_nothing()
	var oc = partial_double(_utils.OrphanCounter).new()
	var d_logger = double(_utils.Logger).new()

	stub(oc, 'orphan_count').to_return(1)
	oc.add_counter('one')
	stub(oc, 'orphan_count').to_return(5)
	oc.print_orphans('one', d_logger)
	var msg = get_call_parameters(d_logger, 'orphan')[0]
	assert_string_contains(msg, 'orphans(')

func test_adding_same_name_overwrites_prev_start_val():
	var oc = partial_double(_utils.OrphanCounter).new()
	stub(oc, 'orphan_count').to_return(1)
	oc.add_counter('one')
	stub(oc, 'orphan_count').to_return(2)
	oc.add_counter('one')
	stub(oc, 'orphan_count').to_return(10)
	assert_eq(oc.get_counter('one'), 8)

func test_getting_count_for_names_that_dne_returns_neg_1():
	var oc = _utils.OrphanCounter.new()
	assert_eq(oc.get_counter('dne'), -1)
