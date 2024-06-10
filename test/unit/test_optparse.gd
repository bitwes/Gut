extends GutTest

class BaseTest:
	extends GutTest

	var OptParse = load('res://addons/gut/cli/optparse.gd')


class TestOption:
	extends BaseTest

	func test_can_make_one():
		var o = OptParse.Option.new('name', 'default')
		assert_not_null(o)

	func test_init_sets_values():
		var o = OptParse.Option.new('name', 'default', 'description')
		assert_eq(o.option_name, 'name')
		assert_eq(o.default, 'default')
		assert_eq(o.description, 'description')

	func test_has_been_set_false_by_default():
		var o = OptParse.Option.new('name', 'default')
		assert_false(o.has_been_set())

	func test_has_been_set_true_after_setting_value():
		var o = OptParse.Option.new('name', 'default')
		o.value = 'value'
		assert_true(o.has_been_set())

	func test_value_returns_default_when_value_not_set():
		var o = OptParse.Option.new('name', 'default')
		assert_eq(o.value, 'default')

	func test_value_returned_when_value_has_been_set():
		var o = OptParse.Option.new('name', 'default')
		o.value = 'value'
		assert_eq(o.value, 'value')

	func test_to_s_replaces_default_with_default_value():
		var o = OptParse.Option.new('name', 'foobar', 'put default here [default]')
		assert_string_ends_with(o.to_s(), 'put default here foobar')

	func test_required_false_by_default():
		var o = OptParse.Option.new('name', 'default')
		assert_false(o.required)


class TestOptParse:
	extends BaseTest

	func test_can_make_one():
		var opts = OptParse.new()
		assert_not_null(opts)

	func test_assigns_default_value():
		var opts = OptParse.new()
		opts.add('--foo', 'bar', 'this is an argument')
		opts.parse([])

		assert_eq(opts.get_value('--foo'), 'bar')
		if(is_failing()):
			opts.print_options()

	func test_get_help_includes_banner():
		var opts = OptParse.new()
		opts.banner = 'Hello there'
		opts.add('--foo', 'bar', 'this is an argument')
		opts.add('--bar', 'foo', 'what else do you know?')
		var help = opts.get_help()
		assert_string_contains(help, "Hello there\n")

	func test_get_help_includes_all_options():
		var opts = OptParse.new()
		opts.banner = 'Hello there'
		opts.add('--foo', 'bar', 'this is an argument')
		opts.add('--bar', 'foo', 'what else do you know?')
		var help = opts.get_help()
		assert_string_contains(help, "--foo")
		assert_string_contains(help, "--bar")

	func test_get_help_replaces_default_values():
		var opts = OptParse.new()
		opts.banner = 'Hello there'
		opts.add('--foo', 'bar', 'foo = [default]')
		opts.add('--bar', 'foo', 'bar = [default]')
		var help = opts.get_help()
		assert_string_contains(help, "foo = bar")
		assert_string_contains(help, "bar = foo")

	func test_when_include_godot_script_option_true_option_is_not_in_unused():
		var opts = OptParse.new()
		opts.parse(['-s', 'res://something.gd'])
		assert_eq(opts.unused, [])

	func test_when_script_option_specified_it_is_set():
		var opts = OptParse.new()
		opts.parse(['-s', 'res://something.gd'])
		assert_eq(opts.options.script_option.value, 'res://something.gd')

	func test_cannot_add_duplicate_options():
		var opts = OptParse.new()
		opts.add('-a', 'a', 'a')
		opts.add('-a', 'a', 'a')
		assert_eq(opts.options.options.size(), 1)

	func test_cannot_add_duplicate_positional_option():
		var opts = OptParse.new()
		opts.add_positional('a', 'a', 'a')
		opts.add_positional('a', 'a', 'a')
		assert_eq(opts.options.positional.size(), 1)

	func test_add_required_sets_required_flag():
		var opts = OptParse.new()
		var result = opts.add_required('-a', 'a', 'a')
		assert_true(result.required)

	func test_add_required_positional_sets_required_flag():
		var opts = OptParse.new()
		var result = opts.add_positional_required('-a', 'a', 'a')
		assert_true(result.required)

	func test_add_required_ignores_duplicates():
		var opts = OptParse.new()
		var first = opts.add('-a', 'a', 'a')
		var result = opts.add_required('-a', 'a', 'a')
		assert_null(result)
		assert_false(first.required)

	func test_add_required_positional_ignores_duplicates():
		var opts = OptParse.new()
		var first = opts.add_positional('-a', 'a', 'a')
		var result = opts.add_positional_required('-a', 'a', 'a')
		assert_null(result)
		assert_false(first.required)

	func test_get_missing_required_options_zero_default():
		var opts = OptParse.new()
		assert_eq(opts.get_missing_required_options().size(), 0)

	func test_non_specified_required_options_included_in_missing():
		var opts = OptParse.new()
		var req1 = opts.add_required('a', 'a', 'a')
		var req2 = opts.add_required('b', 'b', 'b')
		var missing = opts.get_missing_required_options()
		assert_has(missing, req1, 'required 1 in the list')
		assert_has(missing, req2, 'required 2 in the list')

	func test_non_specified_required_positional_options_included_in_missing():
		var opts = OptParse.new()
		var req1 = opts.add_positional_required('a', 'a', 'a')
		var req2 = opts.add_positional_required('b', 'b', 'b')
		var missing = opts.get_missing_required_options()
		assert_has(missing, req1, 'required 1 in the list')
		assert_has(missing, req2, 'required 2 in the list')

	func test_specified_required_options_not_in_missing():
		var opts = OptParse.new()
		var req1 = opts.add_required('-a', 'a', 'a')
		var req2 = opts.add_required('-b', 'b', 'b')
		opts.parse(['-b=something'])
		var missing = opts.get_missing_required_options()
		assert_has(missing, req1, 'required 2 in the list')
		assert_does_not_have(missing, req2, 'required 1 in the list')

	func test_specified_required_positional_options_not_in_missing():
		var opts = OptParse.new()
		var req1 = opts.add_positional_required('a', 'a', 'a')
		var req2 = opts.add_positional_required('b', 'b', 'b')
		opts.parse(['something'])
		var missing = opts.get_missing_required_options()
		assert_does_not_have(missing, req1, 'required 1 in the list')
		assert_has(missing, req2, 'required 2 in the list')

	# func test_get_value_null_by_default():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo'])
	# 	assert_null(cli_p.get_value('--foo'))

	# func test_get_value_returns_default_when_option_not_specified():
	# 	var cli_p = OptParse.CmdLineParser.new(['one'])
	# 	assert_eq(cli_p.get_value('--foo', 'default'), 'default')

	# func test_splits_value_on_equal_sign():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo=bar'])
	# 	assert_eq(cli_p.get_value('--foo'), 'bar')

	# func test_sets_value_when_next_element_when_is_not_an_option():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo', 'bar'])
	# 	assert_eq(cli_p.get_value('--foo'), 'bar')

	# func test_does_not_set_value_when_next_element_when_is_an_option():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo', '--bar'])
	# 	assert_null(cli_p.get_value('--foo'))


	# func test_get_array_value_removes_opt_from_unused_opts():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
	# 	cli_p.get_array_value('--foo')
	# 	var unused = cli_p.get_unused_options()
	# 	assert_ne(unused[0], '--foo')

	# func test_get_value_removes_opt_from_unused_opts():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
	# 	cli_p.get_value('--foo')
	# 	var unused = cli_p.get_unused_options()
	# 	assert_ne(unused[0], '--foo')

	# func test_positional_arguments_appear_in_order_they_were_specified_minus_other_args_and_values():
	# 	var cli_p = OptParse.CmdLineParser.new(
	# 		["--foo=bar", "one", "--bar", "asdf", "two", "three", "--hello", "--world"])
	# 	assert_eq(cli_p.positional_args, ['one', 'two', 'three'])

	# func test_all_options_are_unused_by_default():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
	# 	assert_eq(cli_p.get_unused_options().size(), 3)

	# func test_was_specified_removes_opt_from_unused_opts():
	# 	var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
	# 	cli_p.was_specified('--bar')
	# 	var unused = cli_p.get_unused_options()
	# 	assert_ne(unused[1], '--bar')


class TestBooleanValues:
	extends BaseTest

	func test_gets_default_of_false_when_not_specified():
		var op = OptParse.new()
		op.add('--foo', false, 'foo bar')
		op.parse([])
		assert_false(op.get_value('--foo'))

	func test_gets_default_of_true_when_not_specified():
		var op = OptParse.new()
		op.add('--foo', true, 'foo bar')
		op.parse([])
		assert_true(op.get_value('--foo'))

	func test_is_true_when_specified_and_default_false():
		var op = OptParse.new()
		op.add('--foo', false, 'foo bar')
		op.parse(['--foo'])
		assert_true(op.get_value('--foo'))

	func test_is_false_when_specified_and_default_true():
		var op = OptParse.new()
		op.add('--foo', true, 'foo bar')
		op.parse(['--foo'])
		assert_false(op.get_value('--foo'))

	func test_does_not_get_value_of_unnamed_args_after():
		var op = OptParse.new()
		op.add('--foo', false, 'foo bar')
		op.parse(['--foo', 'asdf'])
		assert_true(op.get_value('--foo'))



class TestArrayParameters:
	extends BaseTest

	func test_get_array_value_parses_commas_when_equal_not_used():
		var op = OptParse.new()
		op.add('--foo', [], 'foo array')
		op.parse(['--foo', 'a,b,c,d'])
		assert_eq(op.get_value('--foo'), PackedStringArray(['a', 'b', 'c', 'd']))




class TestPositionalArguments:
	extends BaseTest

	func test_can_add_positional_argument():
		var op = OptParse.new()
		op.add_positional('first', '', 'the first one')
		assert_eq(op.options.positional.size(), 1)

	func test_non_named_parameter_1_goes_into_positional():
		var op = OptParse.new()
		op.add_positional('first', '', 'the first one')
		op.parse(['this is a value'])
		assert_eq(op.get_value('first'), 'this is a value')

	func test_two_positional_parameters():
		var op = OptParse.new()
		op.add_positional('first', '', 'the first one')
		op.add_positional('second', 'not_set', 'the second one')
		op.parse(['foo', 'bar'])
		assert_eq(op.get_value('first'), 'foo')
		assert_eq(op.get_value('second'), 'bar')

	func test_second_positional_gets_default_when_not_set():
		var op = OptParse.new()
		op.add_positional('first', '', 'the first one')
		op.add_positional('second', 'not_set', 'the second one')
		op.parse(['foo'])
		assert_eq(op.get_value('first'), 'foo')
		assert_eq(op.get_value('second'), 'not_set')

	func test_when_preceeding_parameter_is_bool_positional_gets_set():
		var op = OptParse.new()
		op.add('--bool', false, 'this is a bool')
		op.add_positional('first', '', 'the first one')
		op.parse(['--bool', 'foo'])
		assert_eq(op.get_value('first'), 'foo')
		assert_true(op.get_value('--bool'))



