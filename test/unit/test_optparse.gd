extends GutTest



class TestCmdLineParser:
	extends GutTest

	var OptParse = load('res://addons/gut/optparse2.gd')

	func test_can_make_one():
		var cli_p = OptParse.CmdLineParser.new([])
		assert_not_null(cli_p)

	func test_was_specified_false_for_non_specified_options():
		var cli_p = OptParse.CmdLineParser.new([])
		assert_false(cli_p.was_specified('--foo'))

	func test_was_specified_true_for_specified_options():
		var cli_p = OptParse.CmdLineParser.new(['--foo'])
		assert_true(cli_p.was_specified('--foo'))

	func test_get_value_null_by_default():
		var cli_p = OptParse.CmdLineParser.new(['--foo'])
		assert_null(cli_p.get_value('--foo'))

	func test_get_value_returns_default_when_option_not_specified():
		var cli_p = OptParse.CmdLineParser.new(['one'])
		assert_eq(cli_p.get_value('--foo', 'default'), 'default')

	func test_splits_value_on_equal_sign():
		var cli_p = OptParse.CmdLineParser.new(['--foo=bar'])
		assert_eq(cli_p.get_value('--foo'), 'bar')

	func test_sets_value_when_next_element_when_is_not_an_option():
		var cli_p = OptParse.CmdLineParser.new(['--foo', 'bar'])
		assert_eq(cli_p.get_value('--foo'), 'bar')

	func test_does_not_set_value_when_next_element_when_is_an_option():
		var cli_p = OptParse.CmdLineParser.new(['--foo', '--bar'])
		assert_null(cli_p.get_value('--foo'))

	func test_non_option_args_are_in_poisitional_args():
		var cli_p = OptParse.CmdLineParser.new(['one', 'two', 'three'])
		assert_eq(cli_p.positional_args, ['one', 'two', 'three'])

	func test_positional_arguments_appear_in_order_they_were_specified_minus_other_args_and_values():
		var cli_p = OptParse.CmdLineParser.new(
			["--foo=bar", "one", "--bar", "asdf", "two", "three", "--hello", "--world"])
		assert_eq(cli_p.positional_args, ['one', 'two', 'three'])

	func test_get_array_value_parses_commas_when_equal_not_used():
		var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d'])
		assert_eq(cli_p.get_array_value('--foo'), PackedStringArray(['a', 'b', 'c', 'd']))

	func test_all_options_are_unused_by_default():
		var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
		assert_eq(cli_p.get_unused_options().size(), 3)

	func test_was_specified_removes_opt_from_unused_opts():
		var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
		cli_p.was_specified('--bar')
		var unused = cli_p.get_unused_options()
		assert_ne(unused[1], '--bar')

	func test_get_array_value_removes_opt_from_unused_opts():
		var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
		cli_p.get_array_value('--foo')
		var unused = cli_p.get_unused_options()
		assert_ne(unused[0], '--foo')

	func test_get_value_removes_opt_from_unused_opts():
		var cli_p = OptParse.CmdLineParser.new(['--foo', 'a,b,c,d', '--bar', '--asdf'])
		cli_p.get_value('--foo')
		var unused = cli_p.get_unused_options()
		assert_ne(unused[0], '--foo')




class TestOptParse:
	extends GutTest

	var OptParse = load('res://addons/gut/optparse2.gd')

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


