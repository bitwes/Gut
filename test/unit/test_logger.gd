extends 'res://test/gut_test.gd'

func test_can_warn():
	var l = Logger.new()
	l.warn('something')
	assert_eq(l.get_warnings().size(), 1)

func test_can_error():
	var l = Logger.new()
	l.error('soemthing')
	assert_eq(l.get_errors().size(), 1)

func test_can_info():
	var l = Logger.new()
	l.info('something')
	assert_eq(l.get_infos().size(), 1)

func test_can_debug():
	var l = Logger.new()
	l.debug('something')
	assert_eq(l.get_debugs().size(), 1)

func test_can_deprecate():
	var l = Logger.new()
	l.deprecated('something')
	assert_eq(l.get_deprecated().size(), 1)

func test_clear_clears_all_buffers():
	var l = Logger.new()
	l.debug('a')
	l.info('a')
	l.warn('a')
	l.error('a')
	l.deprecated('a')
	l.clear()
	assert_eq(l.get_debugs().size(), 0, 'debug')
	assert_eq(l.get_infos().size(), 0, 'info')
	assert_eq(l.get_errors().size(), 0, 'error')
	assert_eq(l.get_warnings().size(), 0, 'warnings')
	assert_eq(l.get_deprecated().size(), 0, 'deprecated')

# this is necessary b/c old implementation did weird stuff and
# I'm trying to fix it.
func test_correct_prefix_used():
	var msgs = []
	var l = Logger.new()
	msgs.append(l.debug('a'))
	msgs.append(l.info('a'))
	msgs.append(l.warn('a'))
	msgs.append(l.error('a'))
	msgs.append(l.deprecated('a'))

	assert_ne(msgs[0], msgs[1], '0, 1')
	assert_ne(msgs[1], msgs[2], '1, 2')
	assert_ne(msgs[2], msgs[3], '2, 3')
	assert_ne(msgs[3], msgs[4], '3, 4')

func test_get_set_gut():
	assert_accessors(Logger.new(), 'gut', null, double(Gut).new())


func test_can_get_count_using_type():
	var l = Logger.new()
	l.warn('somethng')
	l.debug('something 2')
	l.debug('something else')
	assert_eq(l.get_count(l.types.debug), 2, 'count debug')
	assert_eq(l.get_count(l.types.warn), 1, 'count warnings')

func test_get_count_with_no_parameter_returns_count_of_all_logs():
	var l = Logger.new()
	l.warn('a')
	l.debug('b')
	l.error('c')
	l.deprecated('d')
	l.info('e')
	assert_eq(l.get_count(), 5)

func test_normal_output_does_not_contain_type():
	var l = Logger.new()
	var result = l._log(l.types.normal, 'hello')
	assert_eq(result, 'hello')

func test_get_set_indent_level():
	var l = Logger.new()
	assert_accessors(l, 'indent_level', 0, 10)

func test_inc_indent():
	var l = Logger.new()
	l.inc_indent()
	l.inc_indent()
	assert_eq(l.get_indent_level(), 2)

func test_dec_indent_does_not_go_below_0():
	var l = Logger.new()
	l.dec_indent()
	l.dec_indent()
	assert_eq(l.get_indent_level(), 0, 'does not go below 0')

func test_dec_indent_decreases():
	var l = Logger.new()
	l.set_indent_level(10)
	l.dec_indent()
	l.dec_indent()
	l.dec_indent()
	assert_eq(l.get_indent_level(), 7)

func test_get_set_indent_string():
	var l = Logger.new()
	assert_accessors(l, 'indent_string', '    ', "\t")

var log_types = Logger.new().types.keys()
func test_can_enable_disable_types(log_type_key = use_parameters(log_types)):
	var l = Logger.new()
	var log_type = l.types[log_type_key]
	assert_true(l.is_type_enabled(log_type), log_type + ' should be enabled by default')
	l.set_type_enabled(log_type, false)
	assert_false(l.is_type_enabled(log_type), log_type + ' should now be disabled')